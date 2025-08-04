local strings = require("cc.strings")
local dfpwm = require("cc.audio.dfpwm")

local speaker = peripheral.find("speaker")

local progress = 0
local volume = 2.0

local function draw()
    local maxw,maxh = term.getSize()
end

local function get(url) -- (req, szTotal)
    local req = http.get(url)
    local szTotal = req.getResponseHeaders()["content-length"]
    return req, szTotal
end

local function chunkify(handle, szTotal)
    local chunks = {}
    local szChunk = 16*1024
    for i=1,szTotal/szChunk do
        local chunk = handle.read(szChunk)
        if chunk==nil then break end
        table.insert(chunks, chunk)
    end
    return chunks
end

local function playFromUrl(url)
    local req,szTotal = get(url)
    local chunks = chunkify(req, szTotal)
    req.close()

    local decoder = dfpwm.make_decoder()
    for i,chunk in ipairs(chunks) do
        progress = (i/#chunks)*100
        local buffer = decoder(chunk)
        while not speaker.playAudio(buffer, volume) do
            os.pullEvent("speaker_audio_empty")
        end
    end
end

local function playFromFile(path)
    -- TODO
end