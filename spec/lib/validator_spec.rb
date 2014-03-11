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

  let(:raw_params) do
    {
      "id" => 1,
      "name" => "Ryan",
      "email" => "ryan@6wunderkinder.com",
      "password" => "fdsafdsa",
      "surname" => "Levick",
      "author" => { "id" => 1, "name" => "Steve" }
    }
  end

  let(:validator) { test_klass.new(raw_params) }

  describe "#require" do
    context "when param is there" do
      let(:new_params) do
        {
          "id" => 1,
          "name" => "Ryan",
          "login" => "ryan@6wunderkinder.com",
          "pword" => "fdsafdsa",
          "surname" => "Levick",
          "author" => { "id" => 1, "name" => "Steve" }
        }
      end

      it { expect(validator.params.to_hash).to eql(new_params) }
    end

    context "when param is missing" do
      it { expect{ validator.require(:foo) }.to raise_error }
    end
  end

  describe "#require_as" do
    context "when param is there" do
      let(:new_params) do
        np = raw_params.dup
        np["nombre"] = np.delete "name"
        np
      end

      it { expect(validator.require_as(name: :nombre).params.to_hash).to eql(new_params) }
    end

    context "when param is missing" do
      it { expect{ validator.require_as(foo: :bar) }.to raise_error }
    end
  end

  describe "#permit" do
    it { expect(validator.permit(:name).params.to_hash).to eql({"name" => "Ryan"}) }
  end

  describe "#permit_as" do
    it { expect(validator.permit_as(name: :nombre).params.to_hash).to eql({"nombre" => "Ryan"}) }
  end
end