ESX = nil

--I Tried making this script printing and bucket handling as dynamically as i could! #Kappa
--Script was within 2 hours so dont judge! :) 
--This script handles only players and not entities, entities should be as easy to make though
--Would love to see your changes!
--For any problem you encounter either try fixing it yourself if you do have some progamming knowledge either contact me about the "BUG" at Fuego#2486

local bucketList = {} --listed via id and returns id
local activeBuckets = {} --Listed via name and returns id
local activeIntegerBuckets = {} --Listed via id and returns name
GlobalState.ESXBuckets = {} --Global BucketList

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


AddEventHandler('esx:playerDropped', function(source, reason)
    local player = source
    
    bucketList[player] = nil
end)

AddEventHandler("esx:playerLoaded",function(src,xPlayer)
    Wait(5000)

    local player = src
    initializePlayerBucket(player)
end)

function initializePlayerBucket(playerSource)
    local src = tonumber(playerSource)

    if GetPlayerName(src) == nil then
        print('[esx_buckets] : Error finding online player')
        return
    end

    if bucketList[src] and bucketList[src] == 0 then
        print('[esx_buckets] : Error initializing players bucket. Player is already in default bucket')
        return
    end

    local currentBucket = 0

    if activeBuckets['default'] == nil then
        activeBuckets['default'] = 0
        activeIntegerBuckets[0] = 'default'
    end

    bucketList[src] = activeBuckets['default']

    informGlobalStateOfBuckets()

    if GetPlayerRoutingBucket(src) ~= 0 then
        SetPlayerRoutingBucket(src,0)
    end

    print('[esx_buckets] : Initializing player bucket because of player spawn '..GetPlayerName(src))
end

function resetPlayerBucket(playerSource)
    local src = tonumber(playerSource)

    if GetPlayerName(src) == nil then
        print('[esx_buckets] : Error finding online player')
        return
    end

    if bucketList[src] == 0 then --I Want everything to be listed dynamically so we can debug properly
        print('[esx_buckets] : Player is already in '..activeIntegerBuckets[bucketList[src]].. ' bucket')
        return
    end

    SetPlayerRoutingBucket(src,activeBuckets['default'])

    Wait(500) --Do it dynamically so we actually know the bucket has changed

    bucketList[src] = activeBuckets[activeIntegerBuckets[GetPlayerRoutingBucket(src)]]

    informGlobalStateOfBuckets()
end

function isPlayerInBucket(playerSource,bucket)
    local src = tonumber(playerSource)

    if GetPlayerName(src) == nil then
        print('[esx_buckets] : Error finding online player')
        return
    end

    if activeBuckets[bucket] == nil then
        print('[esx_buckets] : Bucket with name of '..bucket.. ' does not exist')
        return
    end

    if bucketList[src] == nil then
        print('[esx_buckets] : Error finding player in bucket')
        return
    end 

    if activeIntegerBuckets[bucketList[src]] == bucket then
        return true
    end

    return false
end

function changePlayerBucket(playerSource,bucket)
    local src = tonumber(playerSource)

    if GetPlayerName(src) == nil then
        print('[esx_buckets] : Error finding online player')
        return
    end
    

    local bucketToBeGenerated = math.random(10,999)

    if activeBuckets[bucket] == nil then
        print('[esx_buckets] : Creating bucket '..bucket.. ' with id of '..bucketToBeGenerated)
        activeBuckets[bucket] = bucketToBeGenerated
        activeIntegerBuckets[bucketToBeGenerated] = bucket
        bucketList[src] = activeBuckets[bucket]
    else
        if bucket == activeIntegerBuckets[bucketList[src]] then
            print('[esx_buckets] : Player is already in the same bucket')
            return
        end
        bucketList[src] = activeBuckets[bucket]
    end

    SetPlayerRoutingBucket(src,bucketList[src])


    print('[esx_buckets] : Players Current Bucket : '..activeIntegerBuckets[bucketList[src]].. ' with id of '.. bucketList[src])

    --Everything above is created and printed dynamically simply because we want to be sure for the information we are getting
    Wait(500)
    informGlobalStateOfBuckets()
end

function getPlayersCurrentBucketId(playerSource)
    local src = tonumber(playerSource)
    return bucketList[src]
end

function getPlayersCurrentBucketName(playerSource)
    local src = tonumber(playerSource)
    return activeBuckets[bucketList[src]]
end

function isPlayersInTheSameBucket(playerOne,PlayerTwo)
    playerOne,PlayerTwo = tonumber(playerOne),tonumber(PlayerTwo)

    local list = {
        firstPlayerBucket = GetPlayerRoutingBucket(playerOne),
        secondPlayerBucket = GetPlayerRoutingBucket(PlayerTwo)
    }

    if bucketList[list.firstPlayerBucket] ~= bucketList[list.secondPlayerBucket] then
        return false
    end

    return true
end

function informGlobalStateOfBuckets()
    GlobalState.ESXBuckets = bucketList
end

RegisterCommand('getplayerbucket', function (src,args)
    local player = src
    local xPlayer = ESX.GetPlayerFromId(player)

    if xPlayer.getGroup() == 'user' then
        return
    end

    local id = tonumber(args[1]) 

    if type(id) == 'nil' or id == 0 then
        xPlayer.showNotification('Please provide a valid number')
        return
    end

    if not GetPlayerName(id) then
        xPlayer.showNotification('Player with id of '.. id ..' is not online')
        return
    end
    

    if bucketList[id] == nil then
        xPlayer.showNotification('Something went wrong initializing or changing the players bucket!')
        return
    end

    xPlayer.showNotification(GetPlayerName(id).. '\'s current bucket is '..activeIntegerBuckets[bucketList[id]].. ' with id of '.. bucketList[id])
    
end)

RegisterCommand('changeplayerbucket', function (src,args)
    local player = src
    local xPlayer = ESX.GetPlayerFromId(player)

    if xPlayer.getGroup() == 'user' then
        return
    end

    local id = tonumber(args[1]) 

    if type(id) == 'nil' or id == 0 then
        xPlayer.showNotification('Please provide a valid number')
        return
    end

    if not GetPlayerName(id) then
        xPlayer.showNotification('Player with id of '.. id ..' is not online')
        return
    end

    exports['esx_buckets']:changePlayerBucket(id,args[2])
end)

RegisterCommand('resetplayerbucket', function (src,args)
    local player = src
    local xPlayer = ESX.GetPlayerFromId(player)

    if xPlayer.getGroup() == 'user' then
        return
    end

    local id = tonumber(args[1]) 

    if activeBuckets[bucketList[src]] == 'default' then
        print('[esx_buckets] : Player\'s bucket is already default')
        return
    end

    if type(id) == 'nil' or id == 0 then
        xPlayer.showNotification('Please provide a valid number')
        return
    end

    if not GetPlayerName(id) then
        xPlayer.showNotification('Player with id of '.. id ..' is not online')
        return
    end

    exports['esx_buckets']:resetPlayerBucket(id)
end)

--[[RegisterCommand('intbucket', function (src) --This was made for testing purposes but you can for sure keep it
   initializePlayerBucket(src)
end)]]

exports('isPlayerInBucket', function (playerId,bucketName)
    return isPlayerInBucket(playerId,bucketName)
end)

exports('isPlayersInTheSameBucket', function (playerOneId,playerTwoId)
    return isPlayersInTheSameBucket(playerOneId,playerTwoId)
end)

exports('getPlayersCurrentBucketName', function (playerId)
    return getPlayersCurrentBucketName(playerId)
end)

exports('getPlayersCurrentBucketId', function (playerId)
   return getPlayersCurrentBucketId(playerId)
end)

exports('resetPlayerBucket', function (playerId)
    resetPlayerBucket(playerId)
end)

exports('changePlayerBucket', function (playerId,bucketName)
    changePlayerBucket(playerId,bucketName)
end)