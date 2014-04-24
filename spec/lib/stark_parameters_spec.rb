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
      permit  :awesome
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

    it { expect(validator.params.permitted?).to be_true }
  end

  context "when required param is missing" do
    let(:params) { full_params.except("name")  }

    it { expect{ validator.params }.to raise_error(ActionController::ParameterMissing) }
  end

  context "when required param is nil" do
    let(:params) { full_params["last_name"] = nil; full_params  }

    it { expect(validator.params.to_hash).to include("surname" => "Levick") }
  end

  describe "required param presence: true" do
    let(:test_klass) do
      Class.new do
        include StarkParameters

        require :name, allow_nil: true
      end
    end

    context "when param is missing" do
      let(:params) { {} }

      it { expect{ validator.params }.to raise_error(ActionController::ParameterMissing) }
    end

    context "when param is nil" do
      let(:params) { {"name" => nil} }

      it { expect(validator.params).to eql(params) }
    end
  end

  context "when permitted param is missing" do
    let(:params) { full_params.except("author")  }

    it { expect{ validator.params }.to_not raise_error }
    it { expect(validator.params.to_hash.keys).to_not include("author") }
  end

  context "when permitted param is false" do
    let(:params) { full_params.merge("awesome" => false)  }

    it { expect{ validator.params }.to_not raise_error }
    it { expect(validator.params.to_hash.keys).to include("awesome") }
  end

  context "with multiple params" do
    let(:validator) { test_klass.new(full_params.except("name"), {"name" => "Ryan"}) }

    it { expect(validator.params.to_hash).to include("name" => "Ryan") }
  end
end