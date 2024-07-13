macro exportPatch()
    quote
        export vstdpatch
        export readOnlyQueue, readOnlyQueueComb, fifoPatch
        export resetStdpatchCounter
    end
end
