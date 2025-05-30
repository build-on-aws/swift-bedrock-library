export const defaultModel = {
    modelName: "Athropic Claude 3 Haiku",
    modelId: "anthropic.claude-3-haiku-20240307-v1:0",
    temperatureRange: {
        min: 0,
        max: 1,
        default: 0.5
    },
    maxTokenRange: {
        min: 0,
        max: 8191,
        default: 200
    }
}

export const models = [
    defaultModel,
    // Antropic
    {
        modelName: "Anthropic Claude Instant",
        modelId: "anthropic.claude-instant-v1",
        temperatureRange: {
            min: 0,
            max: 1,
            default: 0.5
        },
        maxTokenRange: {
            min: 0,
            max: 8191,
            default: 200
        }
    },
    {
        modelName: "Anthropic Claude",
        modelId: "anthropic.claude-v2",
        temperatureRange: {
            min: 0,
            max: 1,
            default: 0.5
        },
        maxTokenRange: {
            min: 0,
            max: 8191,
            default: 200
        }
    },
    {
        modelName: "Anthropic Claude 2.1",
        modelId: "anthropic.claude-v2:1",
        temperatureRange: {
            min: 0,
            max: 1,
            default: 0.5
        },
        maxTokenRange: {
            min: 0,
            max: 8191,
            default: 200
        }
    },
    {
        modelName: "Anthropic Claude 3.5 Haiku",
        modelId: "us.anthropic.claude-3-5-haiku-20241022-v1:0",
        temperatureRange: {
            min: 0,
            max: 1,
            default: 0.5
        },
        maxTokenRange: {
            min: 0,
            max: 8191,
            default: 200
        }
    },
    // Amazon
    {
        modelName: "Amazon Nova Micro",
        modelId: "amazon.nova-micro-v1:0",
        temperatureRange: {
            min: 0,
            max: 1,
            default: 0.5
        },
        maxTokenRange: {
            min: 0,
            max: 8191,
            default: 200
        }
    },
    {
        modelName: "Amazon Nova Lite",
        modelId: "amazon.nova-lite-v1:0",
        temperatureRange: {
            min: 0,
            max: 1,
            default: 0.5
        },
        maxTokenRange: {
            min: 0,
            max: 8191,
            default: 200
        }
    },
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
    {
        modelName: "Amazon Titan Text Express",
        modelId: "amazon.titan-text-express-v1",
        temperatureRange: {
            min: 0,
            max: 1,
            default: 0.5
        },
        maxTokenRange: {
            min: 0,
            max: 8191,
            default: 200
        }
    },
    {
        modelName: "Amazon Titan Text Premier",
        modelId: "amazon.titan-text-premier-v1:0",
        temperatureRange: {
            min: 0,
            max: 1,
            default: 0.5
        },
        maxTokenRange: {
            min: 0,
            max: 8191,
            default: 200
        }
    },
    {
        modelName: "Amazon Titan Text Lite",
        modelId: "amazon.titan-text-lite-v1",
        temperatureRange: {
            min: 0,
            max: 1,
            default: 0.5
        },
        maxTokenRange: {
            min: 0,
            max: 8191,
            default: 200
        }
    },
    // {
    //     modelName: "Deep Seek",
    //     modelId: "us.deepseek.r1-v1:0",
    //     temperatureRange: {
    //         min: 0,
    //         max: 1,
    //         default: 0.5
    //     },
    //     maxTokenRange: {
    //         min: 0,
    //         max: 8191,
    //         default: 200
    //     }
    // },
]

export const defaultPayload = {
    prompt: "",
    temperature: defaultModel.temperatureRange.default,
    maxTokens: defaultModel.maxTokenRange.default
}