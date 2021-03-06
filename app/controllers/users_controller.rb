class UsersController <ApplicationController

  before_filter :require_user, only: [:show]
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.valid?
      Stripe.api_key = ENV['STRIPE_SECRET_KEY']
      charge = StripeWrapper::Charge.create(
          :amount => 999,
          :currency => "usd",
          :card => params[:stripeToken], # obtained with Stripe.js
          :description => "Sign up for charge for #{@user.email}"
      )
      if charge.successful?
        @user.save
        handle_invitation

      #We comment this line cuz we are gonna introduce sidekiq
      #App_Mailer.send_welcome_email(@user).deliver

      #now using sidekiq so we label this action as bg-job
        AppMailer.delay.send_welcome_email(@user)
        flash[:success] = 'thanks you for registering with Myflix. Pls sign in now.'

        redirect_to sign_in_path
      else
        flash[:error] = charge.error_message #error_message what's dat?
        render :new
      end
    else
      flash[:error] = 'Invalid user information. Please check the errors below.'
      render :new
    end
  end

  def show
    @user = User.find(params[:id])

  end

  def user_params
    params.require(:user).permit!
  end

  def new_with_invitation_token
    invitation = Invitation.where(token: params[:token]).first
    #checking if we have a validated invitation
    if invitation
      @user = User.new(email: invitation.recipient_email)
      @invitation_token = invitation.token
      render :new
    else
      redirect_to expired_token_path
    end

  end

  private

  def handle_invitation
    if params[:invitation_token].present?
      invitation = Invitation.where(token: params[:invitation_token]).first
      #require 'pry'; binding.pry

      @user.follow(invitation.inviter)
      invitation.inviter.follow(@user)
      #killing the token
      invitation.update_column(:token, nil)
    end
  end
end

