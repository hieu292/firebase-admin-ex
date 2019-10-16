defmodule FirebaseAdminEx.Messaging.Message do
	@moduledoc """
	This module is responsible for representing the
	attributes of FirebaseAdminEx.Message.
	"""
	
	alias __MODULE__
	alias FirebaseAdminEx.Messaging.WebMessage.Config, as: WebMessageConfig
	alias FirebaseAdminEx.Messaging.AndroidMessage.Config, as: AndroidMessageConfig
	alias FirebaseAdminEx.Messaging.APNSMessage.Config, as: APNSMessageConfig
	
	@keys [
		data: %{},
		notification: %{},
		webpush: nil,
		android: nil,
		apns: nil,
		token: "",
		topic: "",
		fcm_options: %{}
	]
	
	@type t :: %__MODULE__{
				   data: map(),
				   notification: map(),
				   webpush: struct(),
				   android: struct(),
				   apns: struct(),
				   token: String.t(),
				   topic: String.t(),
				   fcm_options: map(),
			   }
	
	@derive Jason.Encoder
	defstruct @keys
	
	# Public API
	def new(attributes) do
		%Message{
			data: Map.get(attributes, :data, %{}),
			notification: Map.get(attributes, :notification, %{}),
			fcm_options: Map.get(attributes, :fcm_options, %{}),
			android: Map.get(attributes, :android),
			apns: Map.get(attributes, :apns),
			webpush: Map.get(attributes, :webpush),
			token: Map.get(attributes, :token),
			topic: Map.get(attributes, :topic),
		}
	end
	
	def validate(%Message{} = message) do
		android_message_config = Map.get(attributes, :android)
		apns_message_config = Map.get(attributes, :apns)
		web_message_config = Map.get(attributes, :webpush)
		token = Map.get(attributes, :token)
		topic = Map.get(attributes, :topic)
		
		if((is_nil(token) or token == "") and (is_nil(topic) or topic == "")) do
			{:error, "[Message] token or topic is missing"}
		else
			check_all_configs(message, [:android, :apns, :webpush])
		end
	end
	
	defp check_all_configs(message, []), do: {:ok, message}
	
	defp check_all_configs(message, list_config) when is_list(list_config) do
		[type | rest] = list_config
		case check_config(message, type) do
			{:ok, _} -> check_all_configs(message, rest)
			{:error, error} -> {:error, error}
		end
	end
	
	defp check_config(message, type) do
		config = Map.get(message, type)
		cond do
			is_nil(config) -> {:ok, message}
			not is_nil(config) and type == :android -> AndroidMessageConfig.validate(message)
			not is_nil(config) and type == :webpush -> WebMessageConfig.validate(message)
			not is_nil(config) and type == :apns -> APNSMessageConfig.validate(message)
			true -> {:error, "[Message] token or topic is missing"}
		end
	end
	
	def validate(_), do: {:error, "[Message] Invalid payload"}
end
