require "request/request_router"

describe RequestRouter do
  let(:legit_post_req){ { "method" => "POST", "uri" => URI("/form?variable_1=Operators%2"), 
    "query_params" => "", "incoming_data" => "params1=value1" } }
  let(:router){ RequestRouter.new }

  describe "#authentication_required?" do
  end
end
