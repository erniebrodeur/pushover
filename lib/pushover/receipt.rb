module Pushover
  Receipt = Struct.new(:receipt, :token, keyword_init: true) do
    def get
      %i[receipt token].each { |param| raise "#{param} must be supplied" unless send param }

      Response.create_from_excon_response Excon.get(path: "1/receipts/#{receipt}.json", query: { token: token })
    end
  end
end
