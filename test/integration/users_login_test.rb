require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "login with invalid information" do

    # ログイン用のパスを開く
    get login_path
    # 新しいセッションのフォームが正しく表示されたことを確認
    assert_template 'sessions/new'
    
    # わざと無効なparamsハッシュを使用してセッション用パスにPOST
    post login_path, params: { session: { email: "", password: "" } }
    
    # 新しいセッションのフォームが再度表示され、フラッシュメッセージが追加されることを確認する
    assert_template 'sessions/new'
    assert_not flash.empty?
    
    # 別のページ (Homeページなど) にいったん移動
    get root_path
    
    # 移動先のページでフラッシュメッセージが表示されていないことを確認
    assert flash.empty?

  end
  
  test "login with valid information" do

    # ログイン用のパスを開く
    get login_path
    
    # セッション用パスに有効な情報をpost
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }

    # ログイン用リンクが表示されなくなったことを確認
    assert_redirected_to @user
    follow_redirect!

    # ログアウト用リンクが表示されていることを確認
    assert_template 'users/show'

    # プロフィール用リンクが表示されていることを確認
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end
  
 test "login with valid information followed by logout" do
   
    # ログイン用のパスを開く
    get login_path
    
    # セッション用パスに有効な情報をpostして、ログインされることを確認
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!

    # ログイン用リンクが表示されていることを確認
    assert_template 'users/show'

    # 各種リンクを確認
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)

    # ログアウトしていることを確認
    delete logout_path
    assert_not is_logged_in?

    # ルートページにリダイレクトされていることを確認
    assert_redirected_to root_url
    follow_redirect!

    # 各種リンクを確認
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end
