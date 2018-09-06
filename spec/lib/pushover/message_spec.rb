require 'spec_helper'

module Pushover
  describe Message do
    describe "Attributes" do
      it { is_expected.to have_attributes(attachment: nil) }
      it { is_expected.to have_attributes(device: nil) }
      it { is_expected.to have_attributes(html: nil) }
      it { is_expected.to have_attributes(message: nil) }
      it { is_expected.to have_attributes(priority: nil) }
      it { is_expected.to have_attributes(response: nil) }
      it { is_expected.to have_attributes(sound: nil) }
      it { is_expected.to have_attributes(timestamp: a_kind_of(Numeric)) }
      it { is_expected.to have_attributes(title: nil) }
      it { is_expected.to have_attributes(token: nil) }
      it { is_expected.to have_attributes(url_title: nil) }
      it { is_expected.to have_attributes(url: nil) }
      it { is_expected.to have_attributes(user: nil) }
    end

    it { is_expected.to be_a_kind_of Creatable }

    describe "Instance Signatures" do
      it { is_expected.to respond_to(:push).with(0).argument }
    end

    describe "::push" do
      let(:message) { described_class.new }
      let(:required_params) { { user: '1234', token: '1234', message: 'abcd' } }
      let(:working_message) { described_class.create required_params }
      let(:excon_connection) { Excon.new Api.url }
      let(:body) { { "status": 1, "request": "647d2300-702c-4b38-8b2f-d56326ae460b" } }
      let(:excon_response) { Excon::Response.new(body: Oj.dump(body), status: 200, headers: headers) }
      let(:response) { Response.create original: excon_response }
      let(:headers) do
        {
          "X-Limit-App-Limit":     7500,
          "X-Limit-App-Remaining": 7496,
          "X-Limit-App-Reset":     1_393_653_600
        }
      end


      before do
        allow(Api).to receive(:connection).and_return excon_connection
        allow(excon_connection).to receive(:post).and_return excon_response
        allow(Response).to receive(:create).and_return response
      end

      shared_examples 'required_param' do |param|
        context "when #{param} is not set" do
          before { working_message.instance_variable_set "@#{param}".to_sym, nil }

          it { expect { working_message.push }.to raise_error ArgumentError, /#{param} is a required parameter/ }
        end
      end

      shared_examples 'extra_param' do |param|
        context "when a #{param} is provided" do
          before { working_message.instance_variable_set "@#{param}".to_sym, 'not_nil' }

          it "is expected to add the #{param} to the query" do
            working_message.push
            expect(excon_connection).to have_received(:post).with(body: a_string_including(param.to_s), path: '1/messages.json')
          end
        end
      end

      %i[message token user].each do |param|
        include_examples 'required_param', param
      end

      %i[attachment device html priority sound title url_title url].each do |param|
        include_examples 'extra_param', param
      end

      it 'is expected to call Api.connection.get with query set' do
        working_message.push
        expect(excon_connection).to have_received(:post).with(body: a_kind_of(String), path: '1/messages.json')
      end

      it "is expected to call Response.create with the response set to original" do
        working_message.push
        expect(Response).to have_received(:create).with(original: a_kind_of(Excon::Response))
      end

      it "is expected to call response.process to populate the object" do
        allow(response).to receive(:process).and_call_original
        working_message.push
        expect(response).to have_received(:process)
      end

      it "is expected to return self" do
        expect(working_message.push).to eq working_message
      end
    end
  end
end
