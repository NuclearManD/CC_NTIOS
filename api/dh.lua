
math.randomseed(os.time())

PRIMES = {
    7, 11, 13, 17, 19, 23, 29,
    31, 37, 41, 43, 47, 51, 53
}

N_PRIMES = #PRIMES
XVAL_SZ = 512  -- This is tested
MODULUS = 9999999967

function mul_mod(x, y, m)
    a = 0
    if y > x then
        -- This makes it a little faster
        -- by creating less loop iterations
        tmp = x
        x = y
        y = tmp
    end
    x = x % m
    y = y % m

    -- Multiply
    while y > 0 do
        if y % 2 == 1 then
            a = (a + x) % m
        end
        x = (2 * x) % m
        y = math.floor(y / 2)
    end

    -- Return the product
    return a
end

function pow_mod(b, p, m)
    a = 1
    for i = 1,p do
        a = mul_mod(a, b, m)
    end
    return a
end

function secretToEnigma(secret)
    -- Rotor selections
    A = secret % 10 + 1
    B = math.floor(secret / 10) % 10 + 1
    C = math.floor(secret / 100) % 10 + 1
    -- Rotor location selections
    a = math.floor(secret / 1000) % 96 + 1
    b = math.floor(secret / 96000) % 96 + 1
    c = math.floor(secret / 9216000) % 96 + 1
    -- Generate Enigma instance
    return enigma.crypter(A, B, C, a, b, c)
end

function generateKeySeed()
    q = PRIMES[math.random(N_PRIMES)]
    x = math.random() * XVAL_SZ
    return { x = x, q = q }
end

function smart_recv(remote_id, protocol, timeout)
    _id = -1
    while _id ~= remote_id do
        _id, msg = rednet.receive(protocol, timeout)
        if _id == nil then
            return nil
        end
    end
    return msg
end

-- It is expected at this point that each computer knows to start the exchange
function negotiateSecret(remote_id, protocol)

    -- Select our half of the number
    q = PRIMES[math.random(N_PRIMES)]
    rednet.send(remote_id, q, protocol)
    w = smart_recv(remote_id, protocol, 5)
    if w == nil then
        return nil
    end

    -- Compute the base
    g = q * w

    -- Compute our private data and public key
    x = math.random(XVAL_SZ)
    A = pow_mod(g, x, MODULUS)

    -- Send the public key and get the other public key
    rednet.send(remote_id, A, protocol)
    B = smart_recv(remote_id, protocol, 5)

    -- Compute the shared secret
    s = pow_mod(B, x, MODULUS)

    return s
end

Connection = {
    secret = nil,
    remote = nil,
    protocol = nil
}

function Connection:new(secret, remote, protocol)
    this = {}
    setmetatable(this, self)
    self.__index = self
    self.secret = secret
    self.remote = remote
    self.protocol = protocol

    return this
end

function Connection:send(data)
    data = textutils.serialise(data)

    -- We have to regen the enigma for each transaction so we don't
    -- go out of sync with the remote in the case of a lost packet.
    crypto = secretToEnigma(self.secret)

    text = crypto(data)
    rednet.send(self.remote, text, self.protocol)
end

function Connection:receive(timeout)
    timeout = timeout or 10

    text = smart_recv(self.remote, self.protocol, timeout)
    if text == nil then
        return nil
    end

    -- We have to regen the enigma for each transaction so we don't
    -- go out of sync with the remote in the case of a lost packet.
    crypto = secretToEnigma(self.secret)

    data = crypto(text)

    return textutils.unserialise(data)
end

function serveWithEnigma(protocol, timeout)
    -- Returns a Connection object or nil if timed out

    timeout = timeout or 10

    msg = ""
    while msg ~= "DH-MAGIC" do
        id, msg = rednet.receive(protocol, timeout)
        if id == nil then
            return nil
        end
    end

    -- We got "DH-MAGIC" from somebody, start a secure connection
    secret = negotiateSecret(id, protocol)

    -- Failure to create a shared secret
    if secret == nil then
        return nil
    end

    -- Connected
    return Connection:new(secret, id, protocol)
end

function connectWithEnigma(id, protocol)
    -- Returns a Connection object or nil if timed out

    rednet.send(id, "DH-MAGIC", protocol)

    -- Attempt a secure connection
    secret = negotiateSecret(id, protocol)

    -- Failure to create a shared secret
    if secret == nil then
        return nil
    end

    -- Connected
    return Connection:new(secret, id, protocol)
end

