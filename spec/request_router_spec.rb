require "request/request_router"

describe RequestRouter do
  let(:generic_post_req){
    { "method" => "POST", "uri" => URI("/form?variable_1=Operators%2"),
      "credentials" => nil } }

  let(:unauthorized_post_request){
    { "method" => "POST", "uri" => URI("/logs?variable_1=Operators%2"),
      "credentials" => nil } }


  describe "#authentication_required?" do
    it "returns false for requests that are not accessing a protected route" do
      router = RequestRouter.new(generic_post_req)
      relative_path = generic_post_req["uri"].path
      expect(router.authentication_required?(relative_path)).to eq(false)
    end

    it "returns true for requests that have a protected route in the path" do
      router = RequestRouter.new(unauthorized_post_request)
      relative_path = unauthorized_post_request["uri"].path
      expect(router.authentication_required?(relative_path)).to eq(true)
    end
  end
end
