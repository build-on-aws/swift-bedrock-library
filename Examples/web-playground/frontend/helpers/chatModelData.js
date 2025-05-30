export const defaultChatModel = {
    modelName: "Amazon Nova Lite",
    modelId: "amazon.nova-lite-v1:0",
    temperatureRange: {
        min: 0.0001,
        max: 1,
        default: 0.7
    },
    maxTokenRange: {
        min: 0,
        max: 5000,
        default: 200
    },
    topPRange: {
        default: 0.9,
        min: 0,
        max: 1
    },
    topKRange: {
        min: 0,
        max: null,
        default: 50
    }
}

export const chatModels = [
    defaultModel,
    // Antropic
    {
        modelName: "Athropic Claude 3 Haiku",
        modelId: "anthropic.claude-3-haiku-20240307-v1:0",
        topKRange: {
            max: 500,
            default: 0,
            min: 0
        },
        temperatureRange: {
            min: 0,
            max: 1,
            default: 1
        },
        supportedModality: AnthropicText,
        topPRange: {
            min: 0,
            default: 0.999,
            max: 1
        },
        maxTokenRange: {
            min: 1,
            default: 4096,
            max: 4096
        }
    },
    {
        modelName: "Anthropic Claude Instant",
        modelId: "anthropic.claude-instant-v1",
        topPRange: {
            max: 1,
            min: 0,
            default: 0.999
        },
        temperatureRange: {
            default: 1,
            max: 1,
            min: 0
        },
        topKRange: {
            min: 0,
            max: 500,
            default: 0
        },
        maxTokenRange: {
            default: null,
            min: 1,
            max: null
        }
    },
    {
        modelName: "Anthropic Claude",
        modelId: "anthropic.claude-v2",
        topPRange: {
            min: 0,
            max: 1,
            default: 0.999
        },
        topKRange: {
            max: 500,
            default: 0,
            min: 0
        },
        maxTokenRange: {
            min: 1,
            default: null,
            max: null
        },
        temperatureRange: {
            min: 0,
            max: 1,
            default: 1
        }
    },
    {
        modelName: "Anthropic Claude 2.1",
        modelId: "anthropic.claude-v2:1",
        topPRange: {
            min: 0,
            max: 1,
            default: 0.999
        },
        topKRange: {
            max: 500,
            default: 0,
            min: 0
        },
        maxTokenRange: {
            min: 1,
            default: null,
            max: null
        },
        temperatureRange: {
            min: 0,
            max: 1,
            default: 1
        }
    },
    {
        modelName: "Anthropic Claude 3.5 Haiku",
        modelId: "us.anthropic.claude-3-5-haiku-20241022-v1:0",
        temperatureRange: {
            default: 1,
            min: 0,
            max: 1
        },
        maxTokenRange: {
            max: 8192,
            default: 8192,
            min: 1
        },
        topKRange: {
            default: 0,
            min: 0,
            max: 500
        },
        topPRange: {
            max: 1,
            default: 0.999,
            min: 0
        },
    },
    // TODO: Opus and Sonnet 3.7
    // Amazon Nova
    {
        modelName: "Amazon Nova Micro",
        modelId: "amazon.nova-micro-v1:0",
        temperatureRange: {
            min: 0.0001,
            max: 1,
            default: 0.7
        },
        maxTokenRange: {
            min: 0,
            max: 5000,
            default: 200
        },
        topPRange: {
            default: 0.9,
            min: 0,
            max: 1
        },
        topKRange: {
            min: 0,
            max: null,
            default: 50
        }
    },
    {
        modelName: "Amazon Nova Pro",
        modelId: "amazon.nova-pro-v1:0",
        temperatureRange: {
            min: 0.0001,
            max: 1,
            default: 0.7
        },
        maxTokenRange: {
            min: 0,
            max: 5000,
            default: 200
        },
        topPRange: {
            default: 0.9,
            min: 0,
            max: 1
        },
        topKRange: {
            min: 0,
            max: null,
            default: 50
        }
    },
    // Mistral
    {
        modelName: "Mistral Large (24.02)",
        modelId: "mistral.mistral-large-2402-v1:0",
        temperatureRange: {
            min: 0,
            max: 1,
            default: 0.7
        },
        maxTokenRange: {
            min: 0,
            max: 8191,
            default: 8191
        }
    },
    {
        modelName: "Mistral Small (24.02)",
        modelId: "mistral.mistral-small-2402-v1:0",
        temperatureRange: {
            min: 0,
            max: 1,
            default: 0.7
        },
        maxTokenRange: {
            min: 0,
            max: 8191,
            default: 8191
        }
    },
    // Amazon Titan
    {
        modelName: "Amazon Titan Text Express",
        modelId: "amazon.titan-text-express-v1",
        temperatureRange: {
            max: 1,
            default: 0.7,
            min: 0
        },
        maxTokenRange: {
            max: 8192,
            default: 512,
            min: 0
        },
        topPRange: {
            min: 0,
            default: 0.9,
            max: 1
        },
    },
    {
        modelName: "Amazon Titan Text Premier",
        modelId: "amazon.titan-text-premier-v1:0",
        temperatureRange: {
            min: 0,
            max: 1,
            default: 0.7
        },
        maxTokenRange: {
            min: 0,
            max: 3072,
            default: 512
        },
        topPRange: {
            max: 1,
            default: 0.9,
            min: 0
        }
    },
    {
        modelName: "Amazon Titan Text Lite",
        modelId: "amazon.titan-text-lite-v1",
        topPRange: {
            max: 1,
            default: 0.9,
            min: 0
        },
        maxTokenRange: {
            max: 4096,
            min: 0,
            default: 512
        },
        temperatureRange: {
            default: 0.7,
            max: 1,
            min: 0
        }
    },
    // DeepSeek
    // {
    //     modelName: "Deep Seek",
    //     modelId: "us.deepseek.r1-v1:0",
    //     topPRange: {
    //         max: 1,
    //         default: 1,
    //         min: 0
    //     },
    //     temperatureRange: {
    //         default: 1,
    //         min: 0,
    //         max: 1
    //     },
    //     maxTokenRange: {
    //         max: 32768,
    //         default: 32768,
    //         min: 1
    //     },
    // },
]

export const defaultPayload = {
    prompt: "",
    temperature: defaultModel.temperatureRange.default,
    maxTokens: defaultModel.maxTokenRange.default
}