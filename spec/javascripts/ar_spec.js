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
	    /* register the object */
	    var r = Ar.register('other', q);
	    /* Ar.register returns an object with a 'value' property */
	    var s = r.value;
	    /* We want the property descriptor for the 'rec' property */
	    var t = Object.getOwnPropertyDescriptor(s, 'rec');
	    /*
	     * What we really want is to test IsAccessorProperty but
	     * that doesn't exist so we get the property names and see
	     * if there is a 'get' property
	     */
	    var u = Object.getOwnPropertyNames(t);
	    expect(u).toContain('get');
	});
    });

    describe("AJAX calls", function() {
	var q;
	var new_q;

	beforeEach(function() {
	    spyOn(ArRequestRepository, 'lookup').andCallThrough();

	    q = {
		id: Math.floor(Math.random() * 10000),
		rec: new SpecBelongsToArObject()
	    };

	    new_q = Ar.register('blah', q);
	});

	it("should not fire when registering", function() {
	    expect(ArRequestRepository.lookup).not.toHaveBeenCalled();
	});

	it("should fire when record is accessed", function() {
	    var err;

	    try {
		new_q.value.rec;
	    } catch (t) {
		err = t;
	    }

	    /* Best way I can figure out to test that we threw an ArCookie */
	    expect(err.addListener).isInstanceOf(Function);
	    expect(ArRequestRepository.lookup).toHaveBeenCalled();
	    console.log(ajaxRequests);
	});
    });
});
