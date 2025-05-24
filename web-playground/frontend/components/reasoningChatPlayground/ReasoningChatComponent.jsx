"use client";

import Human from "@/components/reasoningChatPlayground/Human";
import React, { useState } from "react";
import Assistant from "@/components/reasoningChatPlayground/Assistant";
import Loader from "@/components/reasoningChatPlayground/Loader";
import GlobalConfig from "@/app/app.config";
import ReasoningModelSelector from "./ReasoningModelSelector";
import { defaultModel } from "@/helpers/reasoningModelData";
import NumericInput from "../NumericInput";
import Image from 'next/image';


export default function ChatContainer() {
    const [conversation, setConversation] = useState([]);
    const [history, setHistory] = useState([]);
    const [inputValue, setInputValue] = useState("");
    const [isLoading, setIsLoading] = useState(false);
    const [selectedModel, setSelectedModel] = useState(defaultModel);
    const [maxTokens, setMaxTokens] = useState(defaultModel.maxTokenRange.default);
    const [maxReasoningTokens, setMaxReasoningTokens] = useState(defaultModel.maxReasoningTokensRange.default);
    const [temperature, setTemperature] = useState(defaultModel.temperatureRange.default);
    // const [topP, setTopP] = useState(defaultModel.topPRange.default);
    const [stopSequences, setStopSequences] = useState([]);
    const [stopSequenceInput, setStopSequenceInput] = useState('');
    const [referenceImage, setReferenceImage] = useState(null);
    const [previewImage, setPreviewImage] = useState('/placeholder.png');
    const fileInputRef = React.useRef(null);
    const [errorMessage, setErrorMessage] = useState(null);

    const endpoint = `/foundation-models/chat/${selectedModel.modelId}`;
    const api = `${GlobalConfig.apiHost}:${GlobalConfig.apiPort}${endpoint}`;

    const handleInputChange = (e) => {
        setInputValue(e.target.value);
    };

    const onModelChange = (newModel) => {
        setSelectedModel(newModel);
        clearChat()
    }

    const handleMaxTokensChange = (value) => {
        setMaxTokens(value);
    };

    const handleMaxReasoningTokensChange = (value) => {
        setMaxReasoningTokens(value);
    };

    const handleTemperatureChange = (value) => {
        setTemperature(value);
    };

    // const handleTopPChange = (value) => {
    //     setTopP(value);
    // };

    const handleStopSequenceInputChange = (e) => {
        setStopSequenceInput(e.target.value);
    };

    const addStopSequence = () => {
        if (stopSequenceInput.trim()) {
            setStopSequences([...stopSequences, stopSequenceInput.trim()]);
            setStopSequenceInput('');
        }
    };

    const removeStopSequence = (index) => {
        setStopSequences(stopSequences.filter((_, i) => i !== index));
    };

    const clearChat = () => {
        setConversation([]);
        setHistory([]);
    };

    const handleFileUpload = async (event) => {
        const file = event.target.files[0];
        if (file) {
            // Create preview for the UI
            const reader = new FileReader();
            reader.onload = (e) => {
                setPreviewImage(e.target.result);
            };
            reader.readAsDataURL(file);

            // Compress and store the image
            const compressedBase64 = await compressImage(file);
            console.log('Compressed image size:', compressedBase64.length);
            setReferenceImage(compressedBase64);
        }
    };

    const compressImage = (file) => {
        return new Promise((resolve) => {
            const reader = new FileReader();
            reader.onload = (event) => {
                const img = document.createElement('img'); // Use regular img element instead of Next.js Image
                img.onload = () => {
                    const canvas = document.createElement('canvas');
                    // Reduce max dimensions to 512x512
                    const maxSize = 512;
                    let width = img.width;
                    let height = img.height;

                    if (width > height) {
                        if (width > maxSize) {
                            height *= maxSize / width;
                            width = maxSize;
                        }
                    } else {
                        if (height > maxSize) {
                            width *= maxSize / height;
                            height = maxSize;
                        }
                    }

                    canvas.width = width;
                    canvas.height = height;

                    const ctx = canvas.getContext('2d');
                    ctx.drawImage(img, 0, 0, width, height);

                    // Increase compression by reducing quality to 0.5 (50%)
                    const compressedBase64 = canvas.toDataURL('image/jpeg', 0.5);
                    resolve(compressedBase64.split(',')[1]);
                };
                img.src = event.target.result;
            };
            reader.readAsDataURL(file);
        });
    };

    const sendMessage = async () => {
        const currentImage = previewImage !== '/placeholder.png' ? previewImage : null;
        const newMessage = {
            sender: "Human",
            message: inputValue,
            image: currentImage
        };
        setConversation(prevConversation => [...prevConversation, newMessage]);
        setInputValue('');
        setReferenceImage(null);
        setPreviewImage('/placeholder.png');

        if (fileInputRef.current) {
            fileInputRef.current.value = '';
        }

        try {
            setIsLoading(true);
            setErrorMessage(null);

            const response = await fetch(api, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    prompt: inputValue,
                    history: history,
                    imageBytes: referenceImage,
                    maxTokens: parseInt(maxTokens, 10),
                    temperature: parseFloat(temperature),
                    // topP: parseFloat(topP),
                    stopSequences: stopSequences,
                    enableReasoning: true,
                    maxReasoningTokens: parseInt(maxReasoningTokens, 10)
                })
            });

            if (!response.ok) {
                await response.json().then(data => {
                    console.log(data)
                    console.log(data.error.message)
                    let errorMsg = data.error.message
                    setErrorMessage(errorMsg);
                    throw new Error(errorMsg);
                });
            }

            await response.json().then(data => {
                const reasoning = data.reasoningBlock != undefined ? data.reasoningBlock.reasoning : "No reasoning found";
                setConversation(prevConversation => [...prevConversation, {
                    sender: "Assistant",
                    message: data.textReply,
                    reasoning: reasoning
                }]);
                setHistory(data.history);
                console.log(history)
            });

        } catch (error) {
            console.error("Error sending message:", error.message);
        } finally {
            setIsLoading(false);
        }
    };

    return <div className="flex flex-col flex-auto h-full p-6">
        <h3 className="text-3xl font-medium text-gray-700">Reasoning Chat Playground</h3>
        <div className="flex flex-col flex-auto flex-shrink-0 rounded-2xl bg-gray-100 p-4 mt-8">
            {/* model and parameter selection */}
            <div className="sticky top-0 z-10 bg-gray-100 py-4">
                <div className="flex justify-between items-center mb-4">
                    <ReasoningModelSelector model={selectedModel} onModelChange={onModelChange} />
                    <button
                        onClick={clearChat}
                        className="bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-xl"
                    >
                        Clear Chat
                    </button>
                </div>

                {/* Error message display */}
                {errorMessage && (
                    <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-xl mb-4 relative" role="alert">
                        <strong className="font-bold">Error: </strong>
                        <span className="block sm:inline whitespace-pre-wrap">{errorMessage}</span>
                        <button
                            className="absolute top-0 bottom-0 right-0 px-4 py-3"
                            onClick={() => setErrorMessage(null)}
                        >
                            <span className="text-red-500">×</span>
                        </button>
                    </div>
                )}

                <div className="flex flex-row items-center h-16 rounded-xl bg-white w-full px-4 sticky">
                    {/* maxTokens */}
                    <div className="ml-4">
                        <div className="relative">
                            <label htmlFor="nrOfImages">
                                Max.lenght:
                            </label>
                        </div>
                    </div>
                    <div className="ml-4">
                        <NumericInput
                            className="relative w-20"
                            placeholder="1"
                            value={maxTokens}
                            range={{
                                min: defaultModel.maxTokenRange.min,
                                max: defaultModel.maxTokenRange.max,
                                default: defaultModel.maxTokenRange.default
                            }}
                            disabled={isLoading}
                            callback={handleMaxTokensChange}
                        />
                    </div>
                    {/* maxReasoningTokens */}
                    <div className="ml-4">
                        <div className="relative">
                            <label htmlFor="nrOfImages">
                                Max. reasoning lenght:
                            </label>
                        </div>
                    </div>
                    <div className="ml-4">
                        <NumericInput
                            className="relative w-20"
                            placeholder="1"
                            value={maxReasoningTokens}
                            range={{
                                min: defaultModel.maxReasoningTokensRange.min,
                                max: defaultModel.maxReasoningTokensRange.max,
                                default: defaultModel.maxReasoningTokensRange.default
                            }}
                            disabled={isLoading}
                            callback={handleMaxReasoningTokensChange}
                        />
                    </div>
                    {/* temperature */}
                    <div className="ml-4">
                        <div className="relative">
                            <label htmlFor="temperature">
                                Temperature:
                            </label>
                        </div>
                    </div>
                    <div className="ml-4">
                        <NumericInput
                            className="relative w-20"
                            placeholder="0.5"
                            value={temperature}
                            range={{ min: 0, max: 1, default: 0.5 }}
                            disabled={isLoading}
                            callback={handleTemperatureChange}
                        />
                    </div>
                    {/* topP */}
                    {/* <div className="ml-4">
                        <div className="relative">
                            <label htmlFor="TopP">
                                TopP:
                            </label>
                        </div>
                    </div>
                    <div className="ml-4">
                        <NumericInput
                            className="relative w-20"
                            placeholder="0.9"
                            value={topP}
                            range={{ min: 0, max: 1, default: 0.9 }}
                            disabled={isLoading}
                            callback={handleTopPChange}
                        />
                    </div> */}
                    {/* Stop Sequences */}
                    <div className="ml-4">
                        <div className="relative">
                            <label htmlFor="stopSequences">
                                Stop Sequences
                            </label>
                        </div>
                    </div>
                    <div className="flex items-center px-4">
                        <input
                            type="text"
                            value={stopSequenceInput}
                            onChange={handleStopSequenceInputChange}
                            className="flex border rounded-l focus:outline-none focus:border-indigo-300 pl-4 h-10"
                            placeholder="Sequence"
                        />
                        <button
                            onClick={addStopSequence}
                            className="h-10 px-4 bg-indigo-500 text-white rounded-r hover:bg-indigo-600"
                        >
                            Add
                        </button>
                    </div>
                    <div className="flex flex-wrap gap-2 mt-2">
                        {stopSequences.map((sequence, index) => (
                            <div
                                key={index}
                                className="flex items-center bg-gray-200 rounded-full px-3 py-1"
                            >
                                <span className="mr-2">{sequence}</span>
                                <button
                                    onClick={() => removeStopSequence(index)}
                                    className="text-gray-500 hover:text-gray-700"
                                >
                                    ×
                                </button>
                            </div>
                        ))}
                    </div>

                </div>
            </div>

            {/* Conversation window */}
            <div className="flex flex-col h-full overflow-x-auto mb-4">
                <div className="flex flex-col h-full">
                    <div className="grid grid-cols-12 gap-y-2">
                        {conversation.map((item, i) => item.sender === "Assistant" ? (
                            <Assistant text={item.message} reasoning={item.reasoning} key={i} />
                        ) : (
                            <Human text={item.message} image={item.image} key={i} />
                        ))}
                        {isLoading ? (<Loader />) : (<div></div>)}
                    </div>
                </div>
            </div>

            {/* Input window */}
            <div className="sticky bottom-0 bg-gray-100 py-4">
                <div className="flex flex-row items-center h-16 rounded-xl bg-white w-full px-4">
                    {/* Text input */}
                    <div className="flex-grow">
                        <div className="relative w-full">
                            <input
                                type="text"
                                value={inputValue}
                                onChange={handleInputChange}
                                onKeyPress={(event) => {
                                    if (event.key === 'Enter') {
                                        sendMessage();
                                    }
                                }}
                                placeholder="Send a message"
                                className="flex w-full border rounded-xl focus:outline-none focus:border-indigo-300 pl-4 h-10"
                            />
                        </div>
                    </div>
                    {/* Reference image with preview */}
                    <div className="flex items-center px-4">
                        <div className="relative">
                            <label className="bg-indigo-500 hover:bg-indigo-600 text-white px-4 py-2 rounded cursor-pointer">
                                Choose Image
                                <input
                                    type="file"
                                    accept="image/*"
                                    onChange={handleFileUpload}
                                    className="hidden"
                                    ref={fileInputRef}
                                />
                            </label>
                        </div>
                        <div className="ml-2">
                            <Image
                                src={previewImage}
                                alt="Reference image"
                                width="50"
                                height="50"
                            />
                        </div>
                    </div>

                    {/* Send button */}
                    <div className="ml-4">
                        <button
                            type="button"
                            onClick={sendMessage}
                            className="flex items-center justify-center bg-indigo-500 hover:bg-indigo-600 rounded-xl text-white px-4 py-1 flex-shrink-0"
                        >
                            <span>Send</span>
                            <span className="ml-2">
                                <svg
                                    className="w-4 h-4 transform rotate-45 -mt-px"
                                    fill="none"
                                    stroke="currentColor"
                                    viewBox="0 0 24 24"
                                    xmlns="http://www.w3.org/2000/svg"
                                >
                                    <path
                                        strokeLinecap="round"
                                        strokeLinejoin="round"
                                        strokeWidth="2"
                                        d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"
                                    ></path>
                                </svg>
                            </span>
                        </button>
                    </div>

                </div>
            </div>
        </div>
    </div>;
}