shared_examples 'requires sign in' do #space and letter are case-sensitive
  it'redirects to the sign_in_page' do
    # checking if we have an user inside
    session[:user_id] = nil
    action  # the action is one below!
    expect(response).to redirect_to sign_in_path
  end
end

shared_examples 'tokenable' do
  it 'generates a random token when the user is created' do
    expect(object.token).to be_present
  end
end