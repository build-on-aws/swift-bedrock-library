"use client";

export default function Assistant({text, reasoning}) {
    return (
        <div className="col-start-1 col-end-11 p-3 rounded-lg">
            <div className="flex flex-row items-center py-4">
                <div
                    className="flex items-center justify-center h-10 w-10 rounded-full bg-purple-500 flex-shrink-0"
                >
                    ...
                </div>
                <div className="relative ml-3 text-sm bg-purple-100 py-2 px-4 shadow rounded-xl rounded-br-xl">
                    <div>{reasoning}</div>
                </div>
            </div>
            <div className="flex flex-row items-center">
                <div
                    className="flex items-center justify-center h-10 w-10 rounded-full bg-indigo-500 flex-shrink-0"
                >
                    A
                </div>
                <div className="relative ml-3 text-sm bg-white py-2 px-4 shadow rounded-xl rounded-br-xl">
                    <div>{text}</div>
                </div>
            </div>
        </div>
    )
}