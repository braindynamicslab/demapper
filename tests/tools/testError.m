function testError(func, errorId)
try
    func()
    assert(false, ['Supposed to throw ', errorId])
catch ME
    assert(strcmp(ME.identifier, errorId))
end
end
