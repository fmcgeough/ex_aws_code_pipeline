defmodule CreateCustomActionTest do
  use ExUnit.Case

  @opts [
    action_type_setting: [
      entity_url_template: "string",
      execution_url_template: "string",
      revision_url_template: "string",
      third_party_configuration_url: "string"
    ],
    configuration_properties: [
      description: "string",
      key: true,
      name: "string",
      queryable: false,
      required: true,
      secret: false,
      type: "string"
    ]
  ]

  test "custom action creation" do
    input_artifact = [minimum_count: 0, maximum_count: 100]
    output_artifact = [minimum_count: 0, maximum_count: 100]

    val =
      ExAws.CodePipeline.create_custom_action_type(
        "Source",
        "AWS CodeDeploy",
        "string",
        input_artifact,
        output_artifact,
        @opts
      )

    expected = %ExAws.Operation.JSON{
      stream_builder: nil,
      http_method: :post,
      parser: &Function.identity/1,
      error_parser: &Function.identity/1,
      path: "/",
      data: %{
        "actionTypeSetting" => %{
          "entityUrlTemplate" => "string",
          "executionUrlTemplate" => "string",
          "revisionUrlTemplate" => "string",
          "thirdPartyConfigurationUrl" => "string"
        },
        "category" => "Source",
        "configurationProperties" => %{
          "description" => "string",
          "key" => true,
          "name" => "string",
          "queryable" => false,
          "required" => true,
          "secret" => false,
          "type" => "string"
        },
        "inputArtifactDetails" => %{"maximumCount" => 100, "minimumCount" => 0},
        "outputArtifactDetails" => %{"maximumCount" => 100, "minimumCount" => 0},
        "provider" => "AWS CodeDeploy",
        "version" => "string"
      },
      params: %{},
      headers: [
        {"x-amz-target", "CodePipeline_20150709.CreateCustomActionType"},
        {"content-type", "application/x-amz-json-1.1"}
      ],
      service: :codepipeline,
      before_request: nil
    }

    assert expected == val
  end
end
