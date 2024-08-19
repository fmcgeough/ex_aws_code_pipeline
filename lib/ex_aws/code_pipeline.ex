defmodule ExAws.CodePipeline do
  @moduledoc """
  Operations on AWS CodePipeline

  The documentation and types provided lean heavily on the [AWS documentation for
  CodePipeline](https://docs.aws.amazon.com/codepipeline/latest/APIReference/API_Operations.html).
  The AWS documentation is the definitive source of information and should be consulted to
  understand how to use CodePipeline and its API functions.

  Generally the functions take required parameters separately from any optional arguments. The
  optional arguments are passed as a Map (with a defined type).

  The defined types for the Maps used to pass optional arguments use the standard Elixir snake-case
  for keys. The API itself uses camel-case Strings for keys. The library provides the conversion.
  Most of the API keys use a lower-case letter for the first word and upper-case for the subsequent
  words. If there are exceptions to this rule they are handled by the library so an Elixir
  developer can just use standard snake-case for all the keys.

  ## Description

  AWS CodePipeline is a continuous delivery service you can use to model, visualize, and automate
  the steps required to release your software. You can quickly model and configure the different
  stages of a software release process. CodePipeline automates the steps required to release your
  software changes continuously.

  ## Resources

  - [CodePipeline User Guide](https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html)
  - [CodePipeline API Reference Guide](https://docs.aws.amazon.com/codepipeline/latest/APIReference/API_Operations.html)
  - [CLI Reference for CodePipeline}](https://docs.aws.amazon.com/cli/latest/reference/codepipeline/index.html)
  """

  # version of the AWS API

  @version "20150709"
  @namespace "CodePipeline"
  @valid_categories ["Source", "Build", "Deploy", "Test", "Invoke", "Approval"]

  alias ExAws.CodePipeline.Utils
  alias ExAws.Operation.JSON, as: ExAwsOperationJSON

  @typedoc """
  The unique system-generated ID of the job for which you want to confirm receipt.

  Pattern: [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}
  """
  @type job_id() :: binary()

  @typedoc """
  A system-generated random number that CodePipeline uses to ensure that the job is being worked on
  by only one job worker

  Get this number from the response of the `poll_for_jobs/2` request that returned this job.

  - Length Constraints: Minimum length of 1. Maximum length of 50.
  """
  @type nonce() :: binary()

  @typedoc """
  The clientToken portion of the clientId and clientToken pair used to verify that the calling
  entity is allowed access to the job and its details.

  - Length Constraints: Minimum length of 1. Maximum length of 256.
  """
  @type client_token() :: binary()

  @typedoc """
  The Amazon Resource Name (ARN) for CodePipeline to use to either perform actions with
  no action_role_arn, or to use to assume roles for actions with an action_role_arn.

  - Length Constraints: Maximum length of 1024.
  - Pattern: arn:aws(-[\w]+)*:iam::[0-9]{12}:role/.*
  """
  @type role_arn() :: binary()

  @typedoc """
  Used for paging. The next_token is returned by one function
  call and must be passed into the next call to page.

  - Length Constraints: Minimum length of 1. Maximum length of 2048.
  """
  @type next_token() :: binary()

  @typedoc """
  The name of the pipeline

  - Length Constraints: Minimum length of 1. Maximum length of 100.
  - Pattern: [A-Za-z0-9.@\-_]+
  """
  @type pipeline_name() :: binary()

  @typedoc """
  The name of a webhook

  - Length Constraints: Minimum length of 1. Maximum length of 100.
  - Pattern: [A-Za-z0-9.@\-_]+
  """
  @type webhook_name() :: binary()

  @typedoc """
  The id of a pipeline execution

  - Pattern: [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}
  """
  @type pipeline_execution_id() :: binary()

  @typedoc """
  The name of the stage

  - Length Constraints: Minimum length of 1. Maximum length of 100.
  - Pattern: [A-Za-z0-9.@\-_]+
  """
  @type stage_name() :: binary()

  @typedoc """
  Timestamps are formatted according to the ISO 8601 standard. These are often referred to as
  "DateTime" or "Date" parameters.

  Acceptable formats include:

  - YYYY-MM-DDThh:mm:ss.sssTZD (UTC), for example, 2014-10-01T20:30:00.000Z
  - YYYY-MM-DDThh:mm:ss.sssTZD (with offset), for example, 2014-10-01T12:30:00.000-08:00
  - YYYY-MM-DD, for example, 2014-10-01
  - Unix time in seconds, for example, 1412195400. This is sometimes referred to as Unix Epoch time
    and represents the number of seconds since midnight, January 1, 1970 UTC.
  """
  @type timestamp() :: binary() | integer()

  @typedoc """
  Specifies whether artifacts are prevented from transitioning into the stage and being processed by
  the actions in that stage (inbound), or prevented from transitioning from the stage after they
  have been processed by the actions in that stage (outbound).

  Valid Values
  ```
  ["Inbound", "Outbound"]
  ```
  """
  @type transition_type() :: binary()

  @typedoc """
  The reason given to the user that a stage is disabled, such as waiting for manual approval or
  manual tests

  This message is displayed in the pipeline console UI.

  - Length Constraints: Minimum length of 1. Maximum length of 300.
  - Pattern: [a-zA-Z0-9!@ \(\)\.\*\?\-]+
  """
  @type disabled_reason() :: binary()

  @typedoc """
  The category of the custom action, such as a build action or a test action.

  ### Valid Values
  ```
  ["Source", "Build", "Deploy", "Test", "Invoke", "Approval"]
  ```
  """
  @type category() :: binary()

  @typedoc """
  A `t:tag/0` key

  - Length Constraints: Minimum length of 1. Maximum length of 128.
  """
  @type tag_key() :: binary()

  @typedoc """
  A `t:tag/0` value

  - Length Constraints: Minimum length of 1. Maximum length of 256.
  """
  @type tag_value() :: binary()

  @typedoc """
  The provider of the service used in the custom action, such as CodeDeploy

  - Length Constraints: Minimum length of 1. Maximum length of 35.
  - Pattern: [0-9A-Za-z_-]+
  """
  @type provider() :: binary()

  @typedoc """
  The version identifier of the custom action

  - Length Constraints: Minimum length of 1. Maximum length of 9.
  - Pattern: [0-9A-Za-z_-]+
  """
  @type version() :: binary()

  @typedoc """
  The maximum number of pipelines to return in a single call

  To retrieve the remaining pipelines, make another call with the returned nextToken value. The
  minimum value you can specify is 1. The maximum accepted value is 1000.

  - Valid Range: Minimum value of 1. Maximum value of 1000.
  """
  @type max_results() :: integer()

  @typedoc """
  The maximum number of jobs to return in a poll for jobs call.

  - Valid Range: Minimum value of 1.
  """
  @type max_batch_size() :: integer()

  @typedoc """
  The response submitted by a reviewer assigned to an approval action request

  Valid Values
  ```
  ["Approved" | "Rejected"]
  ```
  """
  @type approval_result_status() :: binary()

  @typedoc """
  The summary of the current status of the approval request

  - Length Constraints: Minimum length of 0. Maximum length of 512.
  """
  @type approval_result_summary() :: binary()

  @typedoc """
  The external ID of the run of the action that failed

  - Length Constraints: Minimum length of 1. Maximum length of 1500.
  """
  @type execution_id() :: binary()

  @typedoc """
  The message about the failure

  - Length Constraints: Minimum length of 1. Maximum length of 5000.
  """
  @type message() :: binary()

  @typedoc """
  The type of the failure

  Valid Values
  ```
  ["JobFailed", "ConfigurationError", "PermissionError", "RevisionOutOfSync",
  "RevisionUnavailable", "SystemUnavailable"]
  ```
  """
  @type failure_type() :: binary()

  @typedoc """
  The action declaration's name

  - Length Constraints: Minimum length of 1. Maximum length of 100.
  - Pattern: [A-Za-z0-9.@\-_]+
  """
  @type action_name() :: binary()

  @typedoc """
  AWS Region, such as "us-east-1"

  - Length Constraints: Minimum length of 4. Maximum length of 30.
  """
  @type aws_region_name() :: binary()

  @typedoc """
  A category defines what kind of action can be taken in the stage, and constrains the provider type
  for the action.

  Valid Values
  ```
  ["Source", "Build", "Deploy", "Test", "Invoke", "Approval"]
  ```
  """
  @type action_category() :: binary()

  @typedoc """
  The creator of the action being called

  Valid Values
  ```
  ["AWS", "ThirdParty", "Custom"]
  ```
  """
  @type action_owner() :: binary()

  @typedoc """
  The provider of the service being called by the action

  Valid providers are determined by the action category. For example, an action in the Deploy
  category type might have a provider of CodeDeploy, which would be specified as CodeDeploy.

  - Length Constraints: Minimum length of 1. Maximum length of 35.
  - Pattern: [0-9A-Za-z_-]+
  """
  @type action_provider() :: binary()

  @typedoc """
  URL used in `t:action_type_setting/0`

  - Length Constraints: Minimum length of 1. Maximum length of 2048.
  """
  @type url_template() :: binary()

  @typedoc """
  The description of the action configuration property that is displayed to users.

  - Length Constraints: Minimum length of 1. Maximum length of 160.
  """
  @type description() :: binary()

  @typedoc """
  The name of the action configuration property

  - Length Constraints: Minimum length of 1. Maximum length of 50.
  """
  @type action_configuration_key() :: binary()

  @typedoc """
  The type of the configuration property

  Valid Values
  ```
  ["String", "Number", "Boolean"]
  ```
  """
  @type action_configuration_property_type() :: binary()

  @typedoc """
  The change identifier for the current revision

  - Length Constraints: Minimum length of 1. Maximum length of 100.
  """
  @type change_identifier() :: binary()

  @typedoc """
  The summary of the most recent revision of the artifact.

  - Length Constraints: Minimum length of 1. Maximum length of 2048.
  """
  @type revision_summary() :: binary()

  @typedoc """
  Filters the list of action types to those created by a specified entity.

  Valid Values
  ```
  ["AWS", "ThirdParty", "Custom"]
  ```
  """
  @type action_owner_filter() :: binary()

  @typedoc """
  Region to filter on for the list of action types

  - Length Constraints: Minimum length of 4. Maximum length of 30.
  """
  @type region_filter() :: binary()

  @typedoc """
  The unique identifier of the change that set the state to this revision (for example, a deployment
  ID or timestamp).

  - Length Constraints: Minimum length of 1. Maximum length of 100.
  """
  @type revision_change_id() :: binary()

  @typedoc """
  The system-generated unique ID that identifies the revision number of the action

  - Length Constraints: Minimum length of 1. Maximum length of 1500.
  """
  @type revision_id() :: binary()

  @typedoc """
  A token generated by a job worker, such as a CodeDeploy deployment ID, that a successful job
  provides to identify a partner action in progress.

  Future jobs use this token to identify the running instance of the action. It can be reused to
  return more information about the progress of the partner action. When the action is complete, no
  continuation token should be supplied.

  - Length Constraints: Minimum length of 1. Maximum length of 2048.
  """
  @type continuation_token() :: binary()

  @typedoc """
  The system-generated unique ID used to identify a unique execution request.

  - Length Constraints: Minimum length of 1. Maximum length of 128.
  - Pattern: ^[a-zA-Z0-9-]+$
  """
  @type client_request_token() :: binary()

  @typedoc """
  A JsonPath expression that is applied to the body/payload of the webhook

  The value selected by the JsonPath expression must match the value specified in the MatchEquals
  field. Otherwise, the request is ignored. For more information, see Java JsonPath implementation
  in GitHub.

  - Length Constraints: Minimum length of 1. Maximum length of 150.
  """
  @type json_path() :: binary()

  @typedoc """
  The value selected by the JsonPath expression must match what is supplied in the MatchEquals
  field.

  Otherwise, the request is ignored. Properties from the target action configuration can be included
  as placeholders in this value by surrounding the action configuration key with curly brackets. For
  example, if the value supplied here is "refs/heads/{Branch}" and the target action has an action
  configuration property called "Branch" with a value of "main", the MatchEquals value is evaluated
  as "refs/heads/main".

  - Length Constraints: Minimum length of 1. Maximum length of 150.
  """
  @type match_equals() :: binary()

  @typedoc """
  The percentage of work completed on the action, represented on a scale of 0 to 100 percent.

  - Valid Range: Minimum value of 0. Maximum value of 100.
  """
  @type percent_complete() :: non_neg_integer()

  @typedoc """
  The summary of the current status of the actions.

  - Length Constraints: Minimum length of 1. Maximum length of 2048.
  """
  @type execution_summary() :: binary()

  @typedoc """
  Defines the approach to authentication

  Valid Values
  ```
  ["GITHUB_HMAC", "IP", "UNAUTHENTICATED"]
  ```
  """
  @type authentication() :: binary()

  @typedoc """
  The name of the output of an artifact, such as "My App".

  The input artifact of an action must exactly match the output artifact declared in a preceding
  action, but the input artifact does not have to be the next action in strict sequence from the
  action that provided the output artifact. Actions in parallel can declare different output
  artifacts, which are in turn consumed by different following actions.

  Output artifact names must be unique within a pipeline.

  - Length Constraints: Minimum length of 1. Maximum length of 100.
  - Pattern: [a-zA-Z0-9_\-]+
  """
  @type artifact_name() :: binary()

  @typedoc """
  The property used to configure acceptance of webhooks in an IP address range

  For IP, only the allowed_IP_range property must be set. This property must be set to a valid CIDR
  range.

  - Length Constraints: Minimum length of 1. Maximum length of 100.
  """
  @type allowed_IP_range() :: binary()

  @typedoc """
  The property used to configure GitHub authentication

  For GITHUB_HMAC, only the SecretToken property must be set.

  ## Important

  When creating CodePipeline webhooks, do not use your own credentials or reuse the same secret
  token across multiple webhooks. For optimal security, generate a unique secret token for each
  webhook you create. The secret token is an arbitrary string that you provide, which GitHub uses to
  compute and sign the webhook payloads sent to CodePipeline, for protecting the integrity and
  authenticity of the webhook payloads. Using your own credentials or reusing the same token across
  multiple webhooks can lead to security vulnerabilities.

  - Length Constraints: Minimum length of 1. Maximum length of 100.
  """
  @type secret_token() :: binary()

  @typedoc """
  The type of encryption key, such as an AWS KMS key.

  When creating or updating a pipeline, the value must be set to 'KMS'.
  """
  @type encryption_key_type() :: binary()

  @typedoc """
  The ID used to identify the key. For an AWS KMS key, you can use the key ID, the key ARN, or the
  alias ARN

  ## Note

  Aliases are recognized only in the account that created the AWS KMS key. For cross-account
  actions, you can only use the key ID or key ARN to identify the key. Cross-account actions involve
  using the role from the other account (AccountB), so specifying the key ID will use the key from
  the other account (AccountB).

  - Length Constraints: Minimum length of 1. Maximum length of 400.
  """
  @type encryption_key_id() :: binary()

  @typedoc """
  The S3 bucket used for storing the artifacts for a pipeline

  You can specify the name of an S3 bucket but not a folder in the bucket. A folder to contain the
  pipeline artifacts is created for you based on the name of the pipeline. You can use any S3 bucket
  in the same AWS Region as the pipeline to store your pipeline artifacts.

  - Length Constraints: Minimum length of 3. Maximum length of 63.
  - Pattern: [a-zA-Z0-9\-\.]+
  """
  @type artifact_store_location() :: binary()

  @typedoc """
  The type of the artifact store, such as S3

  Valid Values
  ```
  ["S3"]
  ```
  """
  @type artifact_store_type() :: binary()

  @typedoc """
  Reserved for future use.

  - Length Constraints: Minimum length of 1. Maximum length of 100.
  """
  @type blocker_name() :: binary()

  @typedoc """
  Reserved for future use.

  Valid Values
  ```
  ["Schedule"]
  ```
  """
  @type blocker_type() :: binary()

  @typedoc """
  The name of the pipeline you want to connect to the webhook

  - Length Constraints: Minimum length of 1. Maximum length of 100.
  - Pattern: [A-Za-z0-9.@\-_]+
  """
  @type target_pipeline() :: binary()

  @typedoc """
  The name of the action in a pipeline you want to connect to the webhook

  The action must be from the source (first) stage of the pipeline.

  - Length Constraints: Minimum length of 1. Maximum length of 100.
  - Pattern: [A-Za-z0-9.@\-_]+
  """
  @type target_action() :: binary()

  @typedoc """
  The action's configuration.

  These are key-value pairs that specify input values for an action. For more information, see
  Action Structure Requirements in CodePipeline. For the list of configuration properties for the
  AWS CloudFormation action type in CodePipeline, see Configuration Properties Reference in the AWS
  CloudFormation User Guide. For template snippets with examples, see Using Parameter Override
  Functions with CodePipeline Pipelines in the AWS CloudFormation User Guide.

  - Key Length Constraints: Minimum length of 1. Maximum length of 50.
  - Value Length Constraints: Minimum length of 1. Maximum length of 1000.
  """
  @type action_configuration_map() :: map()

  @typedoc """
  The variable namespace associated with the action

  All variables produced as output by this action fall under this namespace.

  - Length Constraints: Minimum length of 1. Maximum length of 100.
  - Pattern: [A-Za-z0-9@\-_]+
  """
  @type action_namespace() :: binary()

  @typedoc """
  A timeout duration in minutes that can be applied against the ActionType’s default timeout value
  specified in Quotas for AWS CodePipeline.

  This attribute is available only to the manual approval ActionType.

  - Valid Range: Minimum value of 5. Maximum value of 86400.
  """
  @type action_timeout() :: pos_integer()

  @typedoc """
  A map of property names and values. For an action type with no queryable properties, this value
  must be null or an empty map

  For an action type with a queryable property, you must supply that property as a key in the map.
  Only jobs whose action configuration matches the mapped value are returned.

  - Map Entries: Minimum number of 0 items. Maximum number of 1 item.
  - Key Length Constraints: Minimum length of 1. Maximum length of 50.
  - Value Length Constraints: Minimum length of 1. Maximum length of 50.
  - Value Pattern: [a-zA-Z0-9_-]+
  """
  @type query_param() :: map()

  @typedoc """
  A tag is a key-value pair that is used to manage the resource.
  """
  @type tag() ::
          [{:key, tag_key()}, {:value, tag_value()}]
          | %{required(:key) => tag_key(), required(:value) => tag_value()}

  @typedoc """
  Optional input to `list_pipelines/1`
  """
  @type list_pipelines_options() ::
          [{:next_token, next_token()}, {:max_results, max_results()}]
          | %{optional(:next_token) => next_token(), optional(:max_results) => max_results()}

  @typedoc """
  Filter for pipeline executions that have successfully completed the stage in the current pipeline
  version

  - Length Constraints: Minimum length of 1. Maximum length of 100.
  - Pattern: [A-Za-z0-9.@\-_]+
  """
  @type succeeded_in_stage_filter() :: %{optional(:stage_name) => stage_name()} | [{:stage_name, stage_name()}]

  @typedoc """
  The pipeline execution to filter on

  - succeeded_in_stage - Filter for pipeline executions where the stage was successful in the
    current pipeline version. See `t:succeeded_in_stage_filter/0`.
  """
  @type pipeline_execution_filter() ::
          [{:succeeded_in_stage, succeeded_in_stage_filter()}]
          | %{optional(:succeeded_in_stage) => succeeded_in_stage_filter()}

  @typedoc """
  Input to the `list_pipeline_executions/2` function

  - filter - The pipeline execution to filter on. See `t:pipeline_execution_filter/0`.
  - next_token - The token that was returned from the previous `list_pipeline_executions/2` call, which
    can be used to return the next set of pipeline executions in the list.
  - max_results - The maximum number of results to return in a single call. To retrieve the
    remaining results, make another call with the returned next_token value. Pipeline history is
    limited to the most recent 12 months, based on pipeline execution start times. Default value is
    100.
  """
  @type list_pipeline_executions_options ::
          [
            {:max_results, max_results()},
            {:next_token, next_token()},
            {:filter, pipeline_execution_filter()}
          ]
          | %{
              required(:pipeline_name) => pipeline_name(),
              optional(:next_token) => next_token(),
              optional(:max_results) => max_results()
            }

  @typedoc """
  The version number of the pipeline. If you do not specify a version, defaults to the current
  version

  - Valid Range: Minimum value of 1.
  """
  @type get_pipeline_options :: [{:version, integer}] | %{optional(:version) => integer()}

  @typedoc """
  Represents information about the result of an approval request
  """
  @type approval_result() ::
          [{:status, approval_result_status()}, {:summary, approval_result_summary()}]
          | %{required(:status) => approval_result_status(), required(:summary) => approval_result_summary()}

  @typedoc """
  The details about the failure of a job
  """
  @type failure_details() ::
          [
            {:external_execution_id, execution_id()},
            {:message, message()},
            {:type, failure_type()}
          ]
          | %{
              optional(:external_execution_id) => execution_id(),
              required(:message) => message(),
              required(:type) => failure_type()
            }

  @typedoc """
  Represents information about an action configuration property

  - description - The description of the action configuration property that is displayed to users.
  - key - Whether the configuration property is a key
  - name - The name of the action configuration property.
  - queryable - Indicates that the property is used with `poll_for_jobs/2`.
    - When creating a custom action, an action can have up to one queryable property. If it has one,
    that property must be both required and not secret.
    - If you create a pipeline with a custom action type, and that custom action contains a
      queryable property, the value for that configuration property is subject to other
      restrictions. The value must be less than or equal to twenty (20) characters. The value can
      contain only alphanumeric characters, underscores, and hyphens.
  - required - Whether the configuration property is a required value.
  - secret - Whether the configuration property is secret. Secrets are hidden from all calls except
    for `get_job_details/1`, `get_third_party_job_details/2`, `poll_for_jobs/2`, and `poll_for_third_party_jobs/2`.
  - type - The type of the configuration property.
    ### Valid Values
    ```
    ["String", "Number", "Boolean"]
    ```
  """
  @type action_configuration_property ::
          [
            {:description, description()},
            {:key, boolean()},
            {:name, action_configuration_key()},
            {:queryable, boolean()},
            {:required, boolean()},
            {:secret, boolean()},
            {:type, action_configuration_property_type()}
          ]
          | %{
              optional(:description) => description(),
              required(:key) => boolean(),
              required(:name) => action_configuration_key(),
              optional(:queryable) => boolean(),
              required(:required) => boolean(),
              required(:secret) => boolean(),
              optional(:type) => action_configuration_property_type()
            }

  @typedoc """
  Information about the settings for an action type

  - entity_url_template - The URL returned to the CodePipeline console that provides a deep link to
    the resources of the external system, such as the configuration page for a CodeDeploy deployment
    group. This link is provided as part of the action display in the pipeline.
  - execution_url_template - The URL returned to the CodePipeline console that contains a link to
    the top-level landing page for the external system, such as the console page for CodeDeploy.
    This link is shown on the pipeline view page in the CodePipeline console and provides a link to
    the execution entity of the external action.
  - revision_url_template - The URL returned to the CodePipeline console that contains a link to the
    page where customers can update or change the configuration of the external action.
  - third_party_configuration_url - The URL of a sign-up page where users can sign up for an
    external service and perform initial configuration of the action provided by that service.
  """
  @type action_type_setting ::
          [
            {:entity_url_template, url_template()},
            {:execution_url_template, url_template()},
            {:revision_url_template, url_template()},
            {:third_party_configuration_url, url_template()}
          ]
          | %{
              optional(:entity_url_template) => url_template(),
              optional(:execution_url_template) => url_template(),
              optional(:revision_url_template) => url_template(),
              optional(:third_party_configuration_url) => url_template()
            }

  @typedoc """
  Information about the details of an artifact

  - minimum_count - The minimum number of artifacts allowed for the action type.
    Valid Range: Minimum value of 0. Maximum value of 5.
  - maximum_count -The maximum number of artifacts allowed for the action type.
    Valid Range: Minimum value of 0. Maximum value of 5.
  """
  @type artifact_details() ::
          [{:minimum_count, non_neg_integer()}, {:maximum_count, non_neg_integer()}]
          | %{required(:minimum_count) => non_neg_integer(), required(:maximum_count) => non_neg_integer()}

  @typedoc """
  The encryption key used to encrypt the data in the artifact store, such as an AWS Key Management
  Service key. If this is undefined, the default key for Amazon S3 is used.
  """
  @type encryption_key() ::
          [{:type, encryption_key_type()}, {:id, encryption_key_id()}]
          | %{required(:type) => encryption_key_type(), required(:id) => encryption_key_id()}

  @typedoc """
  The S3 bucket where artifacts for the pipeline are stored.

  _Note: You must include either artifact_store or artifact_stores in your pipeline, but you cannot
  use both. If you create a cross-region action in your pipeline, you must use artifact_stores_.
  """
  @type artifact_store() ::
          [
            {:encryption_key, encryption_key()},
            {:location, artifact_store_location()},
            {:type, artifact_store_type()}
          ]
          | %{
              optional(:encryption_key) => encryption_key(),
              required(:location) => artifact_store_location(),
              required(:type) => artifact_store_type()
            }

  @typedoc """
  Represents information about an action type. See [Valid Action Types and Providers in
  CodePipeline](https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#actions-valid-providers).
  """
  @type action_type_id() ::
          %{
            required(:category) => action_category(),
            required(:owner) => action_owner(),
            required(:provider) => action_provider(),
            required(:version) => version()
          }
          | [
              {:category, action_category()},
              {:owner, action_owner()},
              {:provider, action_provider()},
              {:version, version()}
            ]

  @typedoc """
  Represents information about the input of an action

  - name - The name of the output of an artifact, such as "My App".
  """
  @type input_artifact :: %{name: artifact_name()} | [{:name, artifact_name()}]

  @typedoc """
  Represents information about the output of an action

  - name - The name of the output of an artifact, such as "My App".
  """
  @type output_artifact() :: %{name: artifact_name()} | [{:name, artifact_name()}]

  @typedoc """
  Reserved for future use

  - name - Reserved for future use
  - type - Reserved for future use
  """
  @type blocker_declaration ::
          [{:name, blocker_name()}, {:type, blocker_type()}]
          | %{required(:name) => blocker_name(), required(:type) => blocker_type()}

  @typedoc """
  Represents information about an action declaration

  - action_type_id - Specifies the action type and the provider of the action.
  - name - The action declaration's name
  - configuration - The action's configuration
  - input_artifacts - The name or ID of the artifact consumed by the action, such as a test or build
    artifact
  - namespace - The variable namespace associated with the action
  - output_artifacts - The name or ID of the result of the action declaration, such as a test or
    build artifact
  - region - The action declaration's AWS Region, such as us-east-1
  - role_arn - The ARN of the IAM service role that performs the declared action
  - run_order - The order in which actions are run
  - timeout_in_minutes - A timeout duration in minutes that can be applied against the ActionType’s
  default timeout value specified in Quotas for AWS CodePipeline
  """
  @type action_declaration() ::
          [
            {:action_type_id, action_type_id()},
            {:name, action_name()},
            {:configuration, action_configuration_map()},
            {:input_artifacts, [input_artifact()]},
            {:namespace, action_namespace()},
            {:output_artifacts, [output_artifact()]},
            {:region, aws_region_name()},
            {:role_arn, role_arn()},
            {:run_order, pos_integer()},
            {:timeout_in_minutes, action_timeout()}
          ]
          | %{
              required(:action_type_id) => action_type_id(),
              required(:name) => action_name(),
              optional(:configuration) => action_configuration_map(),
              optional(:input_artifacts) => [input_artifact()],
              optional(:namespace) => action_namespace(),
              optional(:output_artifacts) => [output_artifact()],
              optional(:region) => binary(),
              optional(:role_arn) => role_arn(),
              optional(:run_order) => pos_integer(),
              optional(:timeout_in_minutes) => action_timeout()
            }

  @typedoc """
  Represents information about a stage and its definition

  """
  @type stage_declaration() ::
          [{:actions, [action_declaration()]}, {:blockers, [blocker_declaration()]}]
          | %{required(:actions) => [action_declaration()], optional(:blockers) => [blocker_declaration()]}

  @typedoc """
  Optional input to the `create_custom_action_type/5` function

  - configuration_properties - The configuration properties for the custom action.
  - settings - URLs that provide users information about this custom action
  """
  @type create_custom_action_type_optional() ::
          [
            configuration_properties: [action_configuration_property()],
            settings: action_type_setting()
          ]
          | %{
              optional(:configuration_properties) => [action_configuration_property()],
              optional(:settings) => action_type_setting()
            }

  @typedoc """
  Represents the structure of actions and stages to be performed in the pipeline.
  """
  @type pipeline_declaration() ::
          %{
            required(:name) => pipeline_name(),
            required(:role_arn) => role_arn(),
            required(:stages) => [stage_declaration()],
            optional(:artifact_store) => artifact_store(),
            optional(:artifact_stores) => [artifact_store()],
            optional(:version) => integer
          }
          | [
              {:name, pipeline_name()},
              {:role_arn, role_arn()},
              {:stages, [stage_declaration()]},
              {:artifact_store, artifact_store()},
              {:artifact_stores, [artifact_store()]},
              {:version, integer()}
            ]

  @typedoc """
  Optional input for function `poll_for_jobs/3`

  - max_batch_size - The maximum number of jobs to return in a poll for jobs call.
  - query_param - A map of property names and values.
  """
  @type poll_for_jobs_optional() ::
          [{:max_batch_size, max_batch_size()}, {:query_param, query_param()}]
          | %{optional(:max_batch_size) => max_batch_size(), optional(:query_param) => query_param()}

  @typedoc """
  Optional input to `list_webhooks/1`
  """
  @type list_webhooks_options ::
          [{:max_results, max_results()}, {:next_token, next_token()}]
          | %{optional(:max_results) => max_results(), optional(:next_token) => next_token()}

  @typedoc """
  Optional input for function `poll_for_third_party_jobs/2`

  - max_batch_size - The maximum number of jobs to return in a poll for jobs call.
  """
  @type poll_for_third_party_jobs_optional() ::
          [{:max_batch_size, integer()}] | %{optional(:max_batch_size) => pos_integer()}

  @typedoc """
  Optional input for function `put_job_success_result/2`

  - external_execution_id - The system-generated unique ID of this action used to identify this job
    worker in any external systems, such as CodeDeploy.
  - percent_complete - The percentage of work completed on the action, represented on a scale of 0
    to 100 percent.
  """
  @type execution_details() ::
          [
            {:external_execution_id, execution_id()},
            {:percent_complete, percent_complete()},
            {:summary, execution_summary()}
          ]
          | %{
              optional(:external_execution_id) => execution_id(),
              optional(:percent_complete) => percent_complete(),
              optional(:summary) => execution_summary()
            }

  @typedoc """
  Represents information about a current revision

  - change_identifier - The change identifier for the current revision.
  - revision - The revision ID of the current version of an artifact.
  - created - The date and time when the most recent revision of the artifact was created, in
    timestamp format.
  - revision_summary - The summary of the most recent revision of the artifact.
  """
  @type current_revision ::
          [
            {:change_identifier, change_identifier()},
            {:revision, revision_id()},
            {:created, timestamp()},
            {:revision_summary, revision_summary()}
          ]
          | %{
              required(:change_identifier) => change_identifier(),
              required(:revision) => revision_id(),
              optional(:created) => timestamp(),
              optional(:revision_summary) => revision_summary()
            }

  @typedoc """
  Optional input argument for the function `put_job_success_result/2`

  - execution_details - The execution details of the successful job, such as the actions taken by
    the job worker.
  - current_revision - The ID of the current revision of the artifact successfully worked on by the
    job
  - continuation_token -A token generated by a job worker, such as a CodeDeploy deployment ID, that
    a successful job provides to identify a custom action in progress.
  """
  @type put_job_success_result_optional() ::
          [
            {:execution_details, execution_details},
            {:current_revision, current_revision},
            {:continuous_token, continuation_token()}
          ]
          | %{
              optional(:execution_details) => execution_details(),
              optional(:current_revision) => current_revision(),
              optional(:continuation_token) => continuation_token()
            }

  @typedoc """
  Used to get a summary of all CodePipeline action types associated with your account.
  """
  @type list_action_types_options ::
          [
            {:action_owner_filter, action_owner_filter()},
            {:next_token, next_token()},
            {:region_filter, region_filter()}
          ]
          | %{
              optional(:action_owner_filter) => action_owner_filter(),
              optional(:next_token) => next_token(),
              optional(:region_filter) => region_filter()
            }

  @typedoc """
  Represents information about the version (or revision) of an action
  """
  @type action_revision() ::
          [
            {:created, timestamp()},
            {:revision_change_id, revision_change_id()},
            {:revision_id, revision_id()}
          ]
          | %{
              required(:created) => timestamp(),
              required(:revision_change_id) => revision_change_id(),
              required(:revision_id) => revision_id()
            }

  @typedoc """
  Optional input arguments for `put_third_party_job_success_result/3`

  - continuation_token - A token generated by a job worker, such as a CodeDeploy deployment ID, that
    a successful job provides to identify a partner action in progress
  - current_revision - Represents information about a current revision
  - execution_details - The details of the actions taken and results produced on an artifact as it
    passes through stages in the pipeline
  """
  @type put_third_party_job_success_result_optional() ::
          [
            {:continuation_token, continuation_token()},
            {:current_revision, current_revision()},
            {:execution_details, execution_details()}
          ]
          | %{
              optional(:continuation_token) => continuation_token(),
              optional(:current_revision) => current_revision(),
              optional(:execution_details) => execution_details()
            }

  @typedoc """
  Optional input arguments for `start_pipeline_execution/2`

  - client_request_token - The system-generated unique ID used to identify a unique execution
    request.
  """
  @type start_pipeline_execution_optional() ::
          [
            {:client_request_token, client_request_token()}
          ]
          | %{optional(:client_request_token) => client_request_token()}

  @typedoc """
  Properties that configure the authentication applied to incoming webhook trigger requests.

  The required properties depend on the authentication type. For GITHUB_HMAC, only the SecretToken
  property must be set. For IP, only the AllowedIPRange property must be set to a valid CIDR range.
  For UNAUTHENTICATED, no properties can be set.

  - allowed_IP_range - The property used to configure acceptance of webhooks in an IP address range
  - secret_token - The property used to configure GitHub authentication
  """
  @type authentication_configuration() ::
          [
            {:allowed_IP_range, allowed_IP_range()},
            {:secret_token, secret_token()}
          ]
          | %{optional(:allowed_IP_range) => allowed_IP_range(), optional(:secret_token) => secret_token()}

  @typedoc """
  The event criteria that specify when a webhook notification is sent to your URL

  - json_path - A JSONPath expression (JSONPath is a query language for JSON, similar to XPath for
    XML. It allows you to select and extract data from a JSON document) that is applied to the
    body/payload of the webhook
  - match_equals - The value selected by the JsonPath expression must match what is supplied in the
    MatchEquals field.
  """
  @type webhook_filter_rule ::
          [
            {:json_path, json_path()},
            {:match_equals, match_equals()}
          ]
          | %{required(:json_path) => json_path, optional(:match_equals) => match_equals()}

  @typedoc """
  Represents information about a webhook and its definition.
  """
  @type webhook_definition ::
          [
            {:authentication, authentication()},
            {:authentication_configuration, authentication_configuration()},
            {:filters, [webhook_filter_rule()]},
            {:name, webhook_name()},
            {:target_action, target_action()},
            {:target_pipeline, target_pipeline()}
          ]
          | %{
              required(:authentication) => authentication(),
              required(:authentication_configuration) => authentication_configuration(),
              required(:filters) => [webhook_filter_rule()],
              required(:name) => webhook_name(),
              required(:target_action) => target_action(),
              required(:target_pipeline) => target_pipeline()
            }

  @doc """
  Returns information about a specified job and whether that job has been received by the job
  worker. Only used for custom actions.

  ## Examples:

      iex> ExAws.CodePipeline.acknowledge_job("f4f4ff82-2d11-EXAMPLE", "3")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"jobId" => "f4f4ff82-2d11-EXAMPLE", "nonce" => "3"},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.AcknowledgeJob"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec acknowledge_job(job_id(), nonce()) :: ExAws.Operation.JSON.t()
  def acknowledge_job(job_id, nonce) do
    %{job_id: job_id, nonce: nonce}
    |> Utils.camelize_map()
    |> request(:acknowledge_job)
  end

  @doc """
  Confirms a job worker has received the specified job. Only used for partner actions.

  ## Examples:

      iex> ExAws.CodePipeline.acknowledge_third_party_job("ABCXYZ", "f4f4ff82-2d11-EXAMPLE", "3")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "clientToken" => "ABCXYZ",
          "jobId" => "f4f4ff82-2d11-EXAMPLE",
          "nonce" => "3"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.AcknowledgeThirdPartyJob"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec acknowledge_third_party_job(client_token(), job_id(), nonce()) :: ExAws.Operation.JSON.t()
  def acknowledge_third_party_job(client_token, job_id, nonce) do
    %{client_token: client_token, job_id: job_id, nonce: nonce}
    |> Utils.camelize_map()
    |> request(:acknowledge_third_party_job)
  end

  @doc """
  Creates a new custom action that can be used in all pipelines associated
  with the AWS account. Only used for custom actions.

  ## Examples

  The examples below demonstrate using `create_custom_action_type/6` where the final parameter
  (containing optional data) uses either Map data structure or Keyword list. Both produce the same
  output.

      iex> alias ExAws.CodePipeline
      iex> version = 1
      iex> category = "Build"
      iex> provider = "MyJenkinsProviderName"
      iex> input_artifact_details = %{maximum_count: 1, minimum_count: 0}
      iex> output_artifact_details = %{maximum_count: 1, minimum_count: 0}
      iex> opts = %{
      ...>  settings: %{
      ...>    entity_url_template: "https://192.0.2.4/job/{Config:ProjectName}/",
      ...>    execution_url_template: "https://192.0.2.4/job/{Config:ProjectName}/lastSuccessfulBuild/{ExternalExecutionId}/"
      ...> },
      ...> configuration_properties: [
      ...>   %{
      ...>      name: "MyJenkinsExampleBuildProject",
      ...>      type: "String",
      ...>      description: "The name of the build project must be provided when this action is added to the pipeline.",
      ...>      key: true,
      ...>      required: true,
      ...>      secret: false,
      ...>      queryable: false
      ...>    }
      ...>  ]
      ...> }
      iex> map_result = CodePipeline.create_custom_action_type(category, provider, version,
      ...>                                                     input_artifact_details,
      ...>                                                     output_artifact_details,
      ...>                                                     opts)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "category" => "Build",
          "configurationProperties" => [
            %{
              "description" => "The name of the build project must be provided when this action is added to the pipeline.",
              "key" => true,
              "name" => "MyJenkinsExampleBuildProject",
              "queryable" => false,
              "required" => true,
              "secret" => false,
              "type" => "String"
            }
          ],
          "inputArtifactDetails" => %{"maximumCount" => 1, "minimumCount" => 0},
          "outputArtifactDetails" => %{"maximumCount" => 1, "minimumCount" => 0},
          "provider" => "MyJenkinsProviderName",
          "settings" => %{
            "entityUrlTemplate" => "https://192.0.2.4/job/{Config:ProjectName}/",
            "executionUrlTemplate" => "https://192.0.2.4/job/{Config:ProjectName}/lastSuccessfulBuild/{ExternalExecutionId}/"
          },
          "version" => 1
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.CreateCustomActionType"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
      iex> keyword_opts = [
      ...>  settings: [
      ...>    entity_url_template: "https://192.0.2.4/job/{Config:ProjectName}/",
      ...>    execution_url_template: "https://192.0.2.4/job/{Config:ProjectName}/lastSuccessfulBuild/{ExternalExecutionId}/"
      ...>  ],
      ...>  configuration_properties: [
      ...>    [
      ...>      name: "MyJenkinsExampleBuildProject",
      ...>      type: "String",
      ...>      description: "The name of the build project must be provided when this action is added to the pipeline.",
      ...>      key: true,
      ...>      required: true,
      ...>      secret: false,
      ...>      queryable: false
      ...>    ]
      ...>  ]
      ...>]
      iex> keyword_result = CodePipeline.create_custom_action_type(category, provider, version,
      ...>                                                         input_artifact_details,
      ...>                                                         output_artifact_details,
      ...>                                                         keyword_opts)
      iex> map_result == keyword_result
      true
  """
  @spec create_custom_action_type(
          category(),
          provider(),
          version(),
          artifact_details(),
          artifact_details(),
          create_custom_action_type_optional()
        ) :: ExAws.Operation.JSON.t()
  def create_custom_action_type(
        category,
        provider,
        version,
        input_artifact_details,
        output_artifact_details,
        optional_data \\ %{}
      )
      when category in @valid_categories do
    optional_data
    |> keyword_to_map()
    |> Map.merge(%{
      category: category,
      provider: provider,
      version: version,
      input_artifact_details: keyword_to_map(input_artifact_details),
      output_artifact_details: keyword_to_map(output_artifact_details)
    })
    |> Utils.camelize_map()
    |> request(:create_custom_action_type)
  end

  @doc """
  Creates a pipeline

  The `pipeline` argument must include either `artifact_store` or `artifact_stores`. You cannot use
  both. If you create a cross-region action in your pipeline, you must use `artifact_stores`.

  ## Examples

  The examples below demonstrate using `create_pipeline/1` with either Map data
  structure or Keyword list. Both produce the same output.

      iex> maps_pipeline_result = %{
      ...>  role_arn: "arn:aws:iam::111111111111:role/AWS-CodePipeline-Service",
      ...>  stages: [
      ...>    %{
      ...>      name: "Source",
      ...>      actions: [
      ...>        %{
      ...>          name: "Source",
      ...>          action_type_id: %{
      ...>            owner: "AWS",
      ...>            version: "1",
      ...>            category: "Source",
      ...>            provider: "S3"
      ...>          },
      ...>          configuration: %{
      ...>            "S3Bucket" => "awscodepipeline-demo-bucket",
      ...>            "S3ObjectKey" => "aws-codepipeline-s3-aws-codedeploy_linux.zip"
      ...>          },
      ...>          input_artifacts: [],
      ...>          run_order: 1,
      ...>          output_artifacts: [%{name: "MyApp"}]
      ...>        }
      ...>      ]
      ...>    },
      ...>    %{
      ...>      name: "MySecondPipeline",
      ...>      version: 1,
      ...>      artifact_store: %{
      ...>        type: "S3",
      ...>        location: "codepipeline-us-east-1-11EXAMPLE11"
      ...>      },
      ...>      actions: [
      ...>        %{
      ...>          name: "CodePipelineDemoFleet",
      ...>          action_type_id: %{
      ...>            owner: "AWS",
      ...>            version: "1",
      ...>            category: "Deploy",
      ...>            provider: "CodeDeploy"
      ...>          },
      ...>          configuration: %{
      ...>            "ApplicationName" => "CodePipelineDemoApplication",
      ...>            "DeploymentGroupName" => "CodePipelineDemoFleet"
      ...>          },
      ...>          input_artifacts: [%{name: "MyApp"}],
      ...>          run_order: 1,
      ...>          output_artifacts: []
      ...>        }
      ...>      ]
      ...>    }
      ...>  ]
      ...>} |> ExAws.CodePipeline.create_pipeline()
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "pipeline" => %{
            "roleArn" => "arn:aws:iam::111111111111:role/AWS-CodePipeline-Service",
            "stages" => [
              %{
                "actions" => [
                  %{
                    "actionTypeId" => %{
                      "category" => "Source",
                      "owner" => "AWS",
                      "provider" => "S3",
                      "version" => "1"
                    },
                    "configuration" => %{
                      "S3Bucket" => "awscodepipeline-demo-bucket",
                      "S3ObjectKey" => "aws-codepipeline-s3-aws-codedeploy_linux.zip"
                    },
                    "inputArtifacts" => [],
                    "name" => "Source",
                    "outputArtifacts" => [%{"name" => "MyApp"}],
                    "runOrder" => 1
                  }
                ],
                "name" => "Source"
              },
              %{
                "actions" => [
                  %{
                    "actionTypeId" => %{
                      "category" => "Deploy",
                      "owner" => "AWS",
                      "provider" => "CodeDeploy",
                      "version" => "1"
                    },
                    "configuration" => %{
                      "ApplicationName" => "CodePipelineDemoApplication",
                      "DeploymentGroupName" => "CodePipelineDemoFleet"
                    },
                    "inputArtifacts" => [%{"name" => "MyApp"}],
                    "name" => "CodePipelineDemoFleet",
                    "outputArtifacts" => [],
                    "runOrder" => 1
                  }
                ],
                "artifactStore" => %{
                  "location" => "codepipeline-us-east-1-11EXAMPLE11",
                  "type" => "S3"
                },
                "name" => "MySecondPipeline",
                "version" => 1
              }
            ]
          },
          "tags" => []
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.CreatePipeline"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
      iex> keyword_pipeline_result = [
      ...>  role_arn: "arn:aws:iam::111111111111:role/AWS-CodePipeline-Service",
      ...>  stages: [
      ...>    [
      ...>      name: "Source",
      ...>      actions: [
      ...>        [
      ...>          input_artifacts: [],
      ...>          name: "Source",
      ...>          action_type_id: [
      ...>            category: "Source",
      ...>            owner: "AWS",
      ...>            version: "1",
      ...>            provider: "S3"
      ...>          ],
      ...>          output_artifacts: [
      ...>            [
      ...>              name: "MyApp"
      ...>            ]
      ...>          ],
      ...>          configuration: %{
      ...>            "S3Bucket" => "awscodepipeline-demo-bucket",
      ...>            "S3ObjectKey" => "aws-codepipeline-s3-aws-codedeploy_linux.zip"
      ...>          },
      ...>          run_order: 1
      ...>        ]
      ...>      ]
      ...>    ],
      ...>    [
      ...>      name: "Beta",
      ...>      actions: [
      ...>        [
      ...>          input_artifacts: [[name: "MyApp"]],
      ...>          name: "CodePipelineDemoFleet",
      ...>          action_type_id: [
      ...>            category: "Deploy",
      ...>            owner: "AWS",
      ...>            version: "1",
      ...>            provider: "CodeDeploy"
      ...>          ],
      ...>          output_artifacts: [],
      ...>          configuration: %{
      ...>            "ApplicationName" => "CodePipelineDemoApplication",
      ...>            "DeploymentGroupName" => "CodePipelineDemoFleet"
      ...>          },
      ...>          run_order: 1
      ...>        ]
      ...>      ],
      ...>      artifact_store: [
      ...>        type: "S3",
      ...>        location: "codepipeline-us-east-1-11EXAMPLE11"
      ...>      ],
      ...>      name: "MySecondPipeline",
      ...>      version: 1
      ...>    ]
      ...>  ]
      ...>] |> ExAws.CodePipeline.create_pipeline()
      iex> keyword_pipeline_result == maps_pipeline_result
      true
  """
  @spec create_pipeline(pipeline_declaration(), [tag()]) :: ExAws.Operation.JSON.t()
  def create_pipeline(pipeline, tags \\ []) do
    tags =
      case Enum.empty?(tags) do
        false -> Enum.map(tags, &keyword_to_map/1)
        true -> []
      end

    %{pipeline: keyword_to_map(pipeline), tags: tags}
    |> Utils.camelize_map()
    |> request(:create_pipeline)
  end

  @doc """
  Marks a custom action as deleted.

  `PollForJobs` for the custom action will fail after the action
  is marked for deletion. Only used for custom actions.

  ## Examples:

      iex> ExAws.CodePipeline.delete_custom_action_type("Source", "AWS CodeDeploy", "1")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "category" => "Source",
          "provider" => "AWS CodeDeploy",
          "version" => "1"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.DeleteCustomActionType"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec delete_custom_action_type(category(), provider(), version()) :: ExAws.Operation.JSON.t()
  def delete_custom_action_type(category, provider, version)
      when category in ["Source", "Build", "Deploy", "Test", "Invoke", "Approval"] do
    %{"category" => category, "provider" => provider, "version" => version}
    |> request(:delete_custom_action_type)
  end

  @doc """
  Deletes the specified pipeline.

  ## Examples:

      iex> ExAws.CodePipeline.delete_pipeline("MyPipeline")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"name" => "MyPipeline"},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.DeletePipeline"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec delete_pipeline(pipeline_name()) :: ExAws.Operation.JSON.t()
  def delete_pipeline(name) do
    %{"name" => name}
    |> request(:delete_pipeline)
  end

  @doc """
  Deletes a web hook.

  ## Examples:

      iex> ExAws.CodePipeline.delete_webhook("MyWebhook")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"name" => "MyWebhook"},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.DeleteWebhook"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec delete_webhook(webhook_name()) :: ExAws.Operation.JSON.t()
  def delete_webhook(name) when is_binary(name) do
    %{"name" => name}
    |> request(:delete_webhook)
  end

  @doc """
  Removes the connection between the webhook that was created by CodePipeline
  and the external tool with events to be detected. Currently only supported
  for webhooks that target an action type of GitHub.

  ## Examples:

      iex> ExAws.CodePipeline.deregister_webhook_with_third_party("MyWebhook")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"webhookName" => "MyWebhook"},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.DeregisterWebhookWithThirdParty"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec deregister_webhook_with_third_party(webhook_name()) :: ExAws.Operation.JSON.t()
  def deregister_webhook_with_third_party(name) when is_binary(name) do
    %{"webhookName" => name}
    |> request(:deregister_webhook_with_third_party)
  end

  @doc """
  Prevents artifacts in a pipeline from transitioning to the next stage in the pipeline.

  ## Examples:

      iex> ExAws.CodePipeline.disable_stage_transition("pipeline", "stage", "Inbound", "Removing")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "pipelineName" => "pipeline",
          "reason" => "Removing",
          "stageName" => "stage",
          "transitionType" => "Inbound"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.DisableStageTransition"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec disable_stage_transition(pipeline_name(), stage_name(), transition_type(), disabled_reason()) ::
          ExAws.Operation.JSON.t()
  def disable_stage_transition(pipeline_name, stage_name, transition_type, reason)
      when transition_type in ["Inbound", "Outbound"] do
    %{
      "pipelineName" => pipeline_name,
      "stageName" => stage_name,
      "transitionType" => transition_type,
      "reason" => reason
    }
    |> request(:disable_stage_transition)
  end

  @doc """
  Enables artifacts in a pipeline to transition to a stage in a pipeline.

  ## Examples:

      iex> ExAws.CodePipeline.enable_stage_transition("pipeline", "stage", "Inbound")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "pipelineName" => "pipeline",
          "stageName" => "stage",
          "transitionType" => "Inbound"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.EnableStageTransition"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec enable_stage_transition(pipeline_name(), stage_name(), transition_type()) :: ExAws.Operation.JSON.t()
  def enable_stage_transition(pipeline_name, stage_name, transition_type)
      when transition_type in ["Inbound", "Outbound"] do
    %{
      "pipelineName" => pipeline_name,
      "stageName" => stage_name,
      "transitionType" => transition_type
    }
    |> request(:enable_stage_transition)
  end

  @doc """
  Returns information about a job. Only used for custom actions.

  ## Important

  When this API is called, AWS CodePipeline returns temporary credentials for
  the Amazon S3 bucket used to store artifacts for the pipeline, if the action
  requires access to that Amazon S3 bucket for input or output artifacts.
  Additionally, this API returns any secret values defined for the action.

  ## Examples:

      iex> ExAws.CodePipeline.get_job_details("MyJob")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"jobId" => "MyJob"},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.GetJobDetails"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec get_job_details(binary()) :: ExAws.Operation.JSON.t()
  def get_job_details(job_id) do
    %{"jobId" => job_id}
    |> request(:get_job_details)
  end

  @doc """
  Returns the metadata, structure, stages, and actions of a pipeline.

  Can be used to return the entire structure of a pipeline in JSON format,
  which can then be modified and used to update the pipeline structure
  with update_pipeline.

  ## Examples:

      iex> ExAws.CodePipeline.get_pipeline("MyPipeline", [version: 1])
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"name" => "MyPipeline", "version" => 1},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.GetPipeline"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec get_pipeline(pipeline_name(), get_pipeline_options()) :: ExAws.Operation.JSON.t()
  def get_pipeline(name, opts \\ []) do
    opts
    |> keyword_to_map()
    |> Map.merge(%{name: name})
    |> Utils.camelize_map()
    |> request(:get_pipeline)
  end

  @doc """
  Returns information about an execution of a pipeline, including details
  about artifacts, the pipeline execution ID, and the name, version, and
  status of the pipeline.

  ## Examples:

      iex> ExAws.CodePipeline.get_pipeline_execution("MyPipeline", "executionId")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "pipelineExecutionId" => "executionId",
          "pipelineName" => "MyPipeline"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.GetPipelineExecution"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec get_pipeline_execution(pipeline_name(), pipeline_execution_id()) :: ExAws.Operation.JSON.t()
  def get_pipeline_execution(pipeline_name, pipeline_execution_id) do
    %{"pipelineExecutionId" => pipeline_execution_id, "pipelineName" => pipeline_name}
    |> request(:get_pipeline_execution)
  end

  @doc """
  Returns information about the state of a pipeline, including the stages and actions.

  ## Examples:

      iex> ExAws.CodePipeline.get_pipeline_state("MyPipeline")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"name" => "MyPipeline"},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.GetPipelineState"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec get_pipeline_state(pipeline_name()) :: ExAws.Operation.JSON.t()
  def get_pipeline_state(name) do
    %{"name" => name}
    |> request(:get_pipeline_state)
  end

  @doc """
  Requests the details of a job for a third party action. Only used for partner actions.

  IMPORTANT: When this API is called, AWS CodePipeline returns temporary credentials
  for the Amazon S3 bucket used to store artifacts for the pipeline, if the action
  requires access to that Amazon S3 bucket for input or output artifacts. Additionally,
  this API returns any secret values defined for the action.

  ## Examples:

      iex> ExAws.CodePipeline.get_third_party_job_details("MyJob", "ClientToken")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"clientToken" => "ClientToken", "jobId" => "MyJob"},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.GetThirdPartyJobDetails"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec get_third_party_job_details(job_id(), client_token()) :: ExAws.Operation.JSON.t()
  def get_third_party_job_details(job_id, client_token) do
    %{"jobId" => job_id, "clientToken" => client_token}
    |> request(:get_third_party_job_details)
  end

  @doc """
  Gets a summary of all AWS CodePipeline action types associated with your account.

  ## Examples:

      iex> ExAws.CodePipeline.list_action_types([action_owner_filter: "MyFilter", next_token: "ClientToken"])
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"actionOwnerFilter" => "MyFilter", "nextToken" => "ClientToken"},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.ListActionTypes"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec list_action_types(list_action_types_options()) :: ExAws.Operation.JSON.t()
  def list_action_types(opts \\ []) do
    opts
    |> keyword_to_map()
    |> Utils.camelize_map()
    |> request(:list_action_types)
  end

  @doc """
  Gets a summary of the most recent executions for a pipeline.

  ## Examples:

      iex> ExAws.CodePipeline.list_pipeline_executions("MyPipeline")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"pipelineName" => "MyPipeline"},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.ListPipelineExecutions"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec list_pipeline_executions(pipeline_name(), list_pipeline_executions_options()) :: ExAws.Operation.JSON.t()
  def list_pipeline_executions(pipeline_name, list_pipeline_executions_options \\ []) do
    list_pipeline_executions_options
    |> keyword_to_map()
    |> Map.merge(%{pipeline_name: pipeline_name})
    |> Utils.camelize_map()
    |> request(:list_pipeline_executions)
  end

  @doc """
  Gets a summary of all of the pipelines associated with your account.

  ## Examples:

      iex> ExAws.CodePipeline.list_pipelines()
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.ListPipelines"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec list_pipelines(list_pipelines_options()) :: ExAws.Operation.JSON.t()
  def list_pipelines(list_pipelines_options \\ []) do
    list_pipelines_options
    |> keyword_to_map()
    |> Utils.camelize_map()
    |> request(:list_pipelines)
  end

  @doc """
  Gets a listing of all the webhooks in this region for this account.
  The output lists all webhooks and includes the webhook URL and ARN,
  as well the configuration for each webhook.

  Note: If a secret token was provided, it will be redacted in the response.

  ## Examples:

      iex> ExAws.CodePipeline.list_webhooks()
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.ListWebhooks"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec list_webhooks(list_webhooks_options()) :: ExAws.Operation.JSON.t()
  def list_webhooks(list_webhooks_options \\ []) do
    list_webhooks_options
    |> keyword_to_map()
    |> Utils.camelize_map()
    |> request(:list_webhooks)
  end

  @doc """
  Returns information about any jobs for AWS CodePipeline to act upon.
  poll_for_jobs is only valid for action types with "Custom" in the owner field.
  If the action type contains "AWS" or "ThirdParty" in the owner field, the
  poll_for_jobs action returns an error.

  ## Examples:

      iex> ExAws.CodePipeline.poll_for_jobs([category: "Build", owner: "AWS", provider: "AWS CodeDeploy", version: "1"])
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "actionTypeId" => %{
            "category" => "Build",
            "owner" => "AWS",
            "provider" => "AWS CodeDeploy",
            "version" => "1"
          }
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.PollForJobs"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec poll_for_jobs(action_type_id(), poll_for_jobs_optional()) :: ExAws.Operation.JSON.t()
  def poll_for_jobs(action_type_id, poll_for_jobs_optional \\ []) do
    action_type_data = %{action_type_id: keyword_to_map(action_type_id)}

    poll_for_jobs_optional
    |> keyword_to_map()
    |> Map.merge(action_type_data)
    |> Utils.camelize_map()
    |> request(:poll_for_jobs)
  end

  @doc """
  Determines whether there are any third party jobs for a job worker to act on.
  Only used for partner actions.

  ## Important

  When this API is called, AWS CodePipeline returns temporary credentials for
  the Amazon S3 bucket used to store artifacts for the pipeline, if the action
  requires access to that Amazon S3 bucket for input or output artifacts.

  ## Examples:

      iex> ExAws.CodePipeline.poll_for_third_party_jobs([category: "Build", owner: "Custom", provider: "MyProvider", version: "1"])
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "actionTypeId" => %{
            "category" => "Build",
            "owner" => "Custom",
            "provider" => "MyProvider",
            "version" => "1"
          }
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.PollForThirdPartyJobs"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec poll_for_third_party_jobs(action_type_id(), poll_for_third_party_jobs_optional()) :: ExAws.Operation.JSON.t()
  def poll_for_third_party_jobs(action_type_id, opts \\ []) do
    action_type_data =
      action_type_id
      |> keyword_to_map()
      |> Utils.camelize_map()

    opts
    |> keyword_to_map()
    |> Map.merge(%{action_type_id: action_type_data})
    |> Utils.camelize_map()
    |> request(:poll_for_third_party_jobs)
  end

  @doc """
  Provides information to AWS CodePipeline about new revisions to a source
  """
  @spec put_action_revision(pipeline_name(), stage_name(), binary(), action_revision()) :: ExAws.Operation.JSON.t()
  def put_action_revision(pipeline_name, stage_name, action_name, action_revision) do
    revision_details = action_revision |> keyword_to_map() |> Utils.camelize_map()

    %{
      "actionName" => action_name,
      "pipelineName" => pipeline_name,
      "actionRevision" => revision_details,
      "stageName" => stage_name
    }
    |> request(:put_action_revision)
  end

  @doc """
  Provides the response to a manual approval request to AWS CodePipeline.
  Valid responses include Approved and Rejected.
  """
  @spec put_approval_result(pipeline_name(), binary(), stage_name(), binary(), approval_result()) ::
          ExAws.Operation.JSON.t()
  def put_approval_result(pipeline_name, stage_name, action_name, token, result) do
    %{
      "pipelineName" => pipeline_name,
      "actionName" => action_name,
      "stageName" => stage_name,
      "token" => token,
      "result" => %{"status" => result.status, "summary" => result.summary}
    }
    |> request(:put_approval_result)
  end

  @doc """
  Represents the failure of a job as returned to the pipeline by a job worker.
  Only used for custom actions.

  ## Examples:

      iex> ExAws.CodePipeline.put_job_failure_result("MyJob", [external_execution_id: "id", message: "", type: "JobFailed"] )
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "externalExecutionId" => "id",
          "jobId" => "MyJob",
          "message" => "",
          "type" => "JobFailed"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.PutJobFailureResult"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec put_job_failure_result(job_id(), failure_details()) :: ExAws.Operation.JSON.t()
  def put_job_failure_result(job_id, failure_details) do
    failure_details
    |> keyword_to_map()
    |> Map.merge(%{job_id: job_id})
    |> Utils.camelize_map()
    |> request(:put_job_failure_result)
  end

  @doc """
  Represents the success of a job as returned to the pipeline by a job worker.
  Only used for custom actions.
  """
  @spec put_job_success_result(job_id(), put_job_success_result_optional()) :: ExAws.Operation.JSON.t()
  def put_job_success_result(job_id, opts \\ []) do
    opts
    |> keyword_to_map()
    |> Map.merge(%{job_id: job_id})
    |> Utils.camelize_map()
    |> request(:put_job_success_result)
  end

  @doc """
  Represents the failure of a third party job as returned to the pipeline by a job worker.
  Only used for partner actions.
  """
  @spec put_third_party_job_failure_result(job_id(), client_token(), failure_details()) :: ExAws.Operation.JSON.t()
  def put_third_party_job_failure_result(job_id, client_token, failure_details) do
    details =
      failure_details
      |> keyword_to_map()
      |> Utils.camelize_map()

    %{"jobId" => job_id, "clientToken" => client_token, "failureDetails" => details}
    |> request(:put_third_party_job_failure_result)
  end

  @doc """
  Represents the success of a third party job as returned to the pipeline by a job worker.
  Only used for partner actions.
  """
  @spec put_third_party_job_success_result(job_id(), client_token(), put_third_party_job_success_result_optional()) ::
          ExAws.Operation.JSON.t()
  def put_third_party_job_success_result(job_id, client_token, opts \\ []) do
    opts
    |> keyword_to_map()
    |> Map.merge(%{job_id: job_id, client_token: client_token})
    |> Utils.camelize_map()
    |> request(:put_third_party_job_success_result)
  end

  @doc """
  Defines a webhook and returns a unique webhook URL generated by
  CodePipeline.

  This URL can be supplied to third party source hosting
  providers to call every time there's a code change. When CodePipeline
  receives a POST request on this URL, the pipeline defined in the webhook is
  started as long as the POST request satisfied the authentication and filtering
  requirements supplied when defining the webhook. register_webhook_with_third_party
  and deregister_webhook_with_third_party APIs can be used to automatically configure
  supported third parties to call the generated webhook URL.

  ## Examples:

      iex> ExAws.CodePipeline.put_webhook("MyWebHook")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"webhook" => "MyWebHook"},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.PutWebhook"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec put_webhook(webhook_definition()) :: ExAws.Operation.JSON.t()
  def put_webhook(webhook) do
    details =
      webhook
      |> keyword_to_map()
      |> Utils.camelize_map()

    %{"webhook" => details}
    |> request(:put_webhook)
  end

  @doc """
  Configures a connection between the webhook that was created and
  the external tool with events to be detected.

  ## Examples:

      iex> ExAws.CodePipeline.register_webhook_with_third_party("MyWebHook")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"webhookName" => "MyWebHook"},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.RegisterWebhookWithThirdParty"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec register_webhook_with_third_party(webhook_name()) :: ExAws.Operation.JSON.t()
  def register_webhook_with_third_party(webhook_name) do
    %{"webhookName" => webhook_name}
    |> request(:register_webhook_with_third_party)
  end

  @doc """
  Resumes the pipeline execution by retrying the last failed
  actions in a stage

  ## Examples:

      iex> ExAws.CodePipeline.retry_stage_execution("MyPipeline", "MyStage", "ExecutionId")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "pipelineExecutionId" => "ExecutionId",
          "pipelineName" => "MyPipeline",
          "retryMode" => "FAILED_ACTIONS",
          "stageName" => "MyStage"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.RetryStageExecution"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec retry_stage_execution(pipeline_name(), binary(), binary(), binary()) :: ExAws.Operation.JSON.t()
  def retry_stage_execution(pipeline_name, stage_name, pipeline_execution_id, retry_mode \\ "FAILED_ACTIONS") do
    %{
      "pipelineExecutionId" => pipeline_execution_id,
      "pipelineName" => pipeline_name,
      "retryMode" => retry_mode,
      "stageName" => stage_name
    }
    |> request(:retry_stage_execution)
  end

  @doc """
  Starts the specified pipeline.

  Specifically, it begins processing the latest commit to the
  source location specified as part of the pipeline.

  ## Examples:

      iex> ExAws.CodePipeline.start_pipeline_execution("MyPipeline", [client_request_token: "Test"])
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"clientRequestToken" => "Test", "name" => "MyPipeline"},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.StartPipelineExecution"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec start_pipeline_execution(binary(), start_pipeline_execution_optional()) :: ExAws.Operation.JSON.t()
  def start_pipeline_execution(name, opts \\ []) do
    opts
    |> keyword_to_map()
    |> Map.merge(%{name: name})
    |> Utils.camelize_map()
    |> request(:start_pipeline_execution)
  end

  @doc """
  Updates a specified pipeline with edits or changes to its structure.

  Use a JSON file with the pipeline structure in conjunction with update_pipeline
  to provide the full structure of the pipeline. Updating the pipeline increases
  the version number of the pipeline by 1.
  """
  @spec update_pipeline(pipeline_declaration()) :: ExAws.Operation.JSON.t()
  def update_pipeline(pipeline) do
    details =
      pipeline
      |> keyword_to_map()
      |> Utils.camelize_map()

    %{"pipeline" => details}
    |> request(:update_pipeline)
  end

  @doc """
  Provided as a by-pass for developers that want to pass in their
  own JSON instead of relying on the individual functions to format
  the JSON data.

  The action has to be an atom that aligns with one of the CodePipeline
  API calls (see calls above for examples).
  """
  def direct_request(action, data) do
    request(data, action)
  end

  defp keyword_to_map(data) when is_map(data), do: data
  defp keyword_to_map([]), do: %{}
  defp keyword_to_map(data), do: Utils.keyword_to_map(data)

  defp request(data, action) do
    operation = action |> Atom.to_string() |> Macro.camelize()

    ExAwsOperationJSON.new(
      :codepipeline,
      %{
        data: data,
        headers: [
          {"x-amz-target", "#{@namespace}_#{@version}.#{operation}"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
      }
    )
  end
end
