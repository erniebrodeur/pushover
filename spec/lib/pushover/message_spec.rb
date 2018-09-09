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

    it { expect(described_class).to be_a_kind_of(Class) }
    it { is_expected.to be_a_kind_of Creatable }

    describe "Instance Signatures" do
      it { is_expected.to respond_to(:push).with(0).argument }
    end

    describe "::push" do
      let(:body) { { "status": 1, "request": "647d2300-702c-4b38-8b2f-d56326ae460b" } }
      let(:excon_connection) { Excon.new Api.url }
      let(:excon_response) { Excon::Response.new(body: Oj.dump(body), status: 200) }
      let(:params) { { user: '1234', token: '1234', message: 'abcd' } }
      let(:request) { Request.create }
      let(:response) { Response.create original: excon_response }
      let(:working_message) { described_class.create params }

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
            expect(excon_connection).to have_received(:post).with(query: a_hash_including(param.to_s => 'not_nil'), path: '1/messages.json')
          end
        end
      end

      %i[message token user].each do |param|
        include_examples 'required_param', param
      end

      %i[attachment device html priority sound title url_title url].each do |param|
        include_examples 'extra_param', param
      end

      it "is expected to call Request.create with ..." do
        allow(Request).to receive(:create).and_return(request)
        working_message.push
        expect(Request).to have_received(:create).with(no_args)
      end

      it "is expected to return response" do
        expect(working_message.push).to eq response
      end
    end
  end
end
