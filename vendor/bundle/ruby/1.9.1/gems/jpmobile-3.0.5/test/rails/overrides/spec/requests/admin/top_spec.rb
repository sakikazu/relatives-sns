# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), '/../../spec_helper'))

describe Admin::TopController do
  describe "GET 'full_path'" do
    context "PCからのアクセスの場合" do
      before do
        @user_agent = "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322)"
      end
      it '_partial.html.erbが使用されること' do
        get '/admin/top/full_path', {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h2", :content => "_partial.html.erb")
      end
    end

    context "DoCoMoからのアクセスの場合" do
      before do
        @user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
      end
      it '_partial_mobile_docomo.html.erbが使用されること' do
        get '/admin/top/full_path', {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h2", :content => "_partial_mobile_docomo.html.erb")
      end
    end
  end
end
