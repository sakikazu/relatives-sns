require "rails_helper"

RSpec.describe "Rails upgrade smoke checks" do
  it "boots the app with the expected framework and image processor" do
    expect(Rails.version).to match(/\A\d+\.\d+\.\d+/)
    expect(Rails.application.config.active_storage.variant_processor).to eq(:mini_magick)
  end

  it "recognizes the home and sign-in routes" do
    expect(Rails.application.routes.recognize_path("/", method: :get)).to include(controller: "mutters", action: "index")
    expect(Rails.application.routes.recognize_path("/users/sign_in", method: :get)).to include(controller: "users/sessions", action: "new")
  end

  it "loads the asset pipeline and the MiniMagick processor" do
    expect(Sprockets).to be_a(Module)
    expect(ImageProcessing::MiniMagick).to be_a(Module)
  end
end
