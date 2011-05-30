describe('AR', function() {
    describe("register function", function() {
	var o = {
	    id: 1234,
	    foo: 'dog'
	};
	var new_o = Ar.register('temp', o);

	it('can register an object', function() {
	    expect(new_o.value.id).toEqual(1234);
	});

	it("should return an object that sees the same values", function() {
	    expect(new_o.value.foo).toEqual('dog');
	});

	it("return an object that sees updates made via register", function() {
	    var p = {
		id: 1234,
		foo: 'cat'
	    };
	    
	    Ar.register('temp', p);
	    expect(new_o.value.foo).toEqual('cat');
	});

	it("should find and wrap ArObjects", function() {
	    var q = {
		id: 9876,
		rec: new SpecBelongsToArObject()
	    };
	    var r = Ar.register('other', q);
	    var s = r.value;
	    var t = Object.getOwnPropertyDescriptor(s, 'rec');
	    var u = Object.getOwnPropertyNames(t);
	    var v = u.indexOf('get');
	    expect(v).toBeGreaterThan(-1);
	});
    });
});
