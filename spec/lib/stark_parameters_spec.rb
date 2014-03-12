require "spec_helper"

describe StarkParameters do
  let(:test_klass) do
    Class.new do
      include StarkParameters

      require :name
      require :id
      require :email, as: :login
      permit  author: [:id, :name]
      permit  :password, as: :pword
      require [:last_name, :surname]
    end
  end

  let(:full_params) do
    {
      "id" => 1,
      "name" => "Ryan",
      "email" => "ryan@6wunderkinder.com",
      "password" => "fdsafdsa",
      "surname" => "Levick",
      "author" => { "id" => 1, "name" => "Steve" }
    }
  end

  let(:validator) { test_klass.new(params) }

  context "when all params are there" do
    let(:params) { full_params }

    it { expect(validator.params.to_hash).to include("name" => "Ryan") }
    it { expect(validator.params.to_hash).to include("surname" => "Levick") }
    it { expect(validator.params.to_hash).to include("author" => { "id" => 1, "name" => "Steve" }) }
    it { expect(validator.params.to_hash).to include("login" => "ryan@6wunderkinder.com") }
    it { expect(validator.params.to_hash.keys).to_not include("email") }
  end

  context "when required param is missing" do
    let(:params) { full_params.except("name")  }

    it { expect{ validator.params }.to raise_error(ActionController::ParameterMissing) }
  end

  context "when permitted param is missing" do
    let(:params) { full_params.except("author")  }

    it { expect{ validator.params }.to_not raise_error }
    it { expect(validator.params.to_hash.keys).to_not include("author") }
  end
end