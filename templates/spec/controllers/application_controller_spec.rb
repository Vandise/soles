require 'soles_helper'

describe ApplicationController do
  it "performs a command" do
    expect(subject).to receive(:puts).with("Hello from Soles!")
    subject.your_command
  end
end
