# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), '/../spec_helper'))

#
# 携帯からのアクセス
#
describe TemplatePathController, "DoCoMo SH902i からのアクセス" do
  before do
    @user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
  end

  it 'テンプレートの探索順が正しいこと' do
    get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

    controller.lookup_context.mobile.should == [ 'mobile_docomo', 'mobile' ]
  end
end

describe TemplatePathController, "au CA32 からのアクセス" do
  before do
    @user_agent = "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0"
  end
  it 'テンプレートの探索順が正しいこと' do
    get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

    controller.lookup_context.mobile.should == [ 'mobile_au', 'mobile' ]
  end
end

describe TemplatePathController, "Vodafone V903T からのアクセス" do
  before do
    @user_agent = "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0"
  end
  it 'テンプレートの探索順が正しいこと' do
    get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

    controller.lookup_context.mobile.should == [ 'mobile_vodafone', 'mobile_softbank', 'mobile' ]
  end
end

describe TemplatePathController, "SoftBank 910T からのアクセス" do
  before do
    @user_agent = "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
  end
  it 'テンプレートの探索順が正しいこと' do
    get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

    controller.lookup_context.mobile.should == [ 'mobile_softbank', 'mobile' ]
  end
end

describe TemplatePathController, "iPhone からのアクセス" do
  before do
    @user_agent = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16'
  end
  it 'テンプレートの探索順が正しいこと' do
    get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

    controller.lookup_context.mobile.should == [ 'smart_phone_iphone', 'smart_phone' ]
  end
end

describe TemplatePathController, "Android からのアクセス" do
  before do
    @user_agent = 'Mozilla/5.0 (Linux; U; Android 1.6; ja-jp; SonyEriccsonSO-01B Build/R1EA018) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1'
  end
  it 'テンプレートの探索順が正しいこと' do
    get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

    controller.lookup_context.mobile.should == [ 'smart_phone_android', 'smart_phone' ]
  end
end

describe TemplatePathController, "Windows Phone からのアクセス" do
  before do
    @user_agent = 'Mozilla/4.0 (Compatible; MSIE 6.0; Windows NT 5.1 T-01A_6.5; Windows Phone 6.5)'
  end
  it 'テンプレートの探索順が正しいこと' do
    get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

    controller.lookup_context.mobile.should == [ 'smart_phone_windows_phone', 'smart_phone' ]
  end
end

describe TemplatePathController, "integrated_views" do
  describe "index" do
    context "PCからのアクセスの場合" do
      before do
        @user_agent = "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322)"
      end
      it 'index.html.erbが使用されること' do
        get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h1", :content => "index.html.erb")
      end
    end

    context "DoCoMoからのアクセスの場合" do
      before do
        @user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
      end
      it 'index_mobile_docomo.html.erbが使用されること' do
        get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h1", :content => "index_mobile_docomo.html.erb")
      end

      it 'show.html.erb がなくとも show_mobile_docomo.html.erbが使用されること' do
        get "/template_path/show", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h1", :content => "show_mobile_docomo.html.erb")
      end

      it 'disable_mobile_view! のときには index.html.erb が使用されること' do
        get "/template_path/index", {:pc => true}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h1", :content => "index.html.erb")
      end
    end

    context "SoftBankからのアクセスの場合" do
      before do
        @user_agent = "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
      end
      it 'index_mobile.html.erbが使用されること' do
        get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h1", :content => "index_mobile.html.erb")
      end

      it 'show.html.erb がなくとも show_mobile.html.erbが使用されること' do
        get "/template_path/show", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h1", :content => "show_mobile.html.erb")
      end
    end

    context "iPhoneからのアクセスの場合" do
      before do
        @user_agent = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16'
      end
      it 'smart_phone_iphone.html.erbが使用されること' do
        get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h1", :content => "smart_phone_iphone.html.erb")
      end
    end

    context "Androidからのアクセスの場合" do
      before do
        @user_agent = 'Mozilla/5.0 (Linux; U; Android 1.6; ja-jp; SonyEriccsonSO-01B Build/R1EA018) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1'
      end
      it 'smart_phone.html.erbが使用されること' do
        get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h1", :content => "smart_phone.html.erb")
      end
    end

    context "Windows Phoneからのアクセスの場合" do
      before do
        @user_agent = 'Mozilla/4.0 (Compatible; MSIE 6.0; Windows NT 5.1 T-01A_6.5; Windows Phone 6.5)'
      end
      it 'smart_phone.html.erbが使用されること' do
        get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h1", :content => "smart_phone.html.erb")
      end
    end
  end

  context 'only smart_phone view' do
    context 'iPadからのアクセスの場合' do
      before do
        @user_agent = 'Mozilla/5.0 (iPad; U; CPU OS 4_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8F191 Safari/6533.18.5'
      end
      it 'smart_phone_only.html.erbが使用されること' do
        get '/template_path/smart_phone_only', {}, {'HTTP_USER_AGENT' => @user_agent}

        response.should have_tag('h1', :content => 'smart_phone_only_smart_phone.html.erb')
      end
    end

    context 'Android Tabletからのアクセスの場合' do
      before do
        @user_agent = 'Mozilla/5.0 (Linux; U; Android 2.2; ja-jp; SC-01C Build/FROYO) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'
      end
      it 'smart_phone_only.html.erbが使用されること' do
        get '/template_path/smart_phone_only', {}, {'HTTP_USER_AGENT' => @user_agent}

        response.should have_tag('h1', :content => 'smart_phone_only_smart_phone.html.erb')
      end
    end
  end

  context 'with_tblt view' do
    context 'iPadからのアクセスの場合' do
      before do
        @user_agent = 'Mozilla/5.0 (iPad; U; CPU OS 4_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8F191 Safari/6533.18.5'
      end
      it 'with_tblt_tablet.html.erbが使用されること' do
        get '/template_path/with_tblt', {}, {'HTTP_USER_AGENT' => @user_agent}

        response.should have_tag('h1', :content => 'with_tblt_tablet.html.erb')
      end
    end

    context 'Android Tabletからのアクセスの場合' do
      before do
        @user_agent = 'Mozilla/5.0 (Linux; U; Android 2.2; ja-jp; SC-01C Build/FROYO) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'
      end
      it 'with_tblt_tablet.html.erbが使用されること' do
        get '/template_path/with_tblt', {}, {'HTTP_USER_AGENT' => @user_agent}

        response.should have_tag('h1', :content => 'with_tblt_tablet.html.erb')
      end
    end
  end

  context 'with_ipd view' do
    context 'iPadからのアクセスの場合' do
      before do
        @user_agent = 'Mozilla/5.0 (iPad; U; CPU OS 4_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8F191 Safari/6533.18.5'
      end
      it 'with_ipd_tablet_ipad.html.erbが使用されること' do
        get '/template_path/with_ipd', {}, {'HTTP_USER_AGENT' => @user_agent}

        response.should have_tag('h1', :content => 'with_ipd_tablet_ipad.html.erb')
      end
    end

    context 'Android Tabletからのアクセスの場合' do
      before do
        @user_agent = 'Mozilla/5.0 (Linux; U; Android 2.2; ja-jp; SC-01C Build/FROYO) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'
      end
      it 'with_ipd.html.erbが使用されること' do
        get '/template_path/with_ipd', {}, {'HTTP_USER_AGENT' => @user_agent}

        response.should have_tag('h1', :content => 'with_ipd.html.erb')
      end
    end
  end

  context "partial" do
    context "PCからのアクセスの場合" do
      before do
        @user_agent = "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322)"
      end
      it '_partial.html.erbが使用されること' do
        get "/template_path/partial", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h2", :content => "_partial.html.erb")
      end
    end

    context "DoCoMoからのアクセスの場合" do
      before do
        @user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
      end
      it '_partial_mobile_docomo.html.erbが使用されること' do
        get "/template_path/partial", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h2", :content => "_partial_mobile_docomo.html.erb")
      end
    end

    context "SoftBankからのアクセスの場合" do
      before do
        @user_agent = "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
      end
      it '_partial_mobile.html.erbが使用されること' do
        get "/template_path/partial", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h2", :content => "_partial_mobile.html.erb")
      end
    end

    context "iPhoneからのアクセスの場合" do
      before do
        @user_agent = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16'
      end
      it '_partial_smart_phone_iphone.html.erbが使用されること' do
        get "/template_path/partial", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h2", :content => "_partial_smart_phone_iphone.html.erb")
      end
    end

    context "Androidからのアクセスの場合" do
      before do
        @user_agent = 'Mozilla/5.0 (Linux; U; Android 1.6; ja-jp; SonyEriccsonSO-01B Build/R1EA018) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1'
      end
      it '_partial_smart_phone.html.erbが使用されること' do
        get "/template_path/partial", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h2", :content => "_partial_smart_phone.html.erb")
      end
    end

    context "Windows Phoneからのアクセスの場合" do
      before do
        @user_agent = 'Mozilla/4.0 (Compatible; MSIE 6.0; Windows NT 5.1 T-01A_6.5; Windows Phone 6.5)'
      end
      it '_partial_smart_phone.html.erbが使用されること' do
        get "/template_path/partial", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h2", :content => "_partial_smart_phone.html.erb")
      end
    end
  end

  context "full_path_partial" do
    context "PCからのアクセスの場合" do
      before do
        @user_agent = "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322)"
      end
      it '_partial.html.erbが使用されること' do
        get "/template_path/full_path_partial", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h2", :content => "_partial.html.erb")
      end
    end

    context "DoCoMoからのアクセスの場合" do
      before do
        @user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
      end
      it '_partial_mobile_docomo.html.erbが使用されること' do
        get "/template_path/full_path_partial", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h2", :content => "_partial_mobile_docomo.html.erb")
      end
    end
  end
end
