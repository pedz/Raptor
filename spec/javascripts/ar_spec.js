/*
 * Tested so far: (y means that it won't be tested)
 *
 * y ArObject#magic
 * y ArObject#class_name
 * y ArObject#id
 * y ArObject#association_type
 * y ArObject#url
 * y ArObject#element
 *
 * x ArRequest#started
 * x ArRequest#start
 *   ArRequest#succeeded
 *   ArRequest#completed
 * x ArRequest#cookie
 *
 * x ArCookie#addListener
 * x ArCookie#runListeners
 *
 * x ArGetter#get
 *
 * x ArRequestRepository.clearRepository
 * x ArRequestRepository.lookup
 *
 * x Ar.wrap (via Ar.register)
 * x Ar.clearRepository
 * x Ar.register
 * x Ar.lookup
 *   Ar.render
 *
 * Also need to test when element is set on the initial register of an
 * object.
 */
describe('AR', function() {
    /*
     * This tests all of the Ar functionality.  The sequence of states
     * or steps that are tested:
     *   1) The initial object is registered.
     *
     *   2) When an object is registered, it will have ArObjects
     *      within it that will be replace with an ArGetter.
     *
     *   3) The ArGetter is accessed, it will do a number of things
     *      including start an AJAX call.
     *
     *   4) When the AJAX call completes, a number of things will
     *      happen as well.
     */

    describe("register of an object", function() {
	var q;
	var o = {
	    id: 1234,
	    foo: 'dog'
	};
	var new_o = Ar.register('temp', o);

	it('should return an object whoes value property is the original object', function() {
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
	    q = {
		id: 9876,
		ar_objects: {
		    rec: new SpecBelongsToArObject()
		}
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

    describe("AJAX call for belongs_to", function() {
	var getTransportSpy;
	var lookupSpy;
	var saved_rec;
	var new_q;

	beforeEach(function() {
	    Ar.clearRepository();
	    ArRequestRepository.clearRepository();

	    getTransportSpy = Ajax.getTransport;

	    saved_rec = new SpecBelongsToCachedCall();
	    q = {
		id: Math.floor(Math.random() * 10000),
		ar_objects: {
		    rec: saved_rec
		}
	    };

	    new_q = Ar.register('blah', q);
	    lookupSpy = spyOn(ArRequestRepository, "lookup").andCallThrough();
	});

	it("should not fire when registering", function() {
	    expect(Ajax.getTransport).not.toHaveBeenCalled();
	});

	it("should not have called lookup", function() {
	    expect(ArRequestRepository.lookup).not.toHaveBeenCalled();
	});

	describe("accessing the record", function() {
	    var request;
	    var saved_err;

	    beforeEach(function() {
		// Accessing rec will throw an ArCookie
		try {
		    new_q.value.rec;
		} catch (err) {
		    saved_err = err;
		}
		request = mostRecentAjaxRequest();
	    });

	    it("should fire when record is accessed", function() {
		expect(Ajax.getTransport).toHaveBeenCalled();
	    });

	    it("Ajax.getTransport should only be called once", function() {
		expect(getTransportSpy.callCount).toEqual(1);
	    });

	    it("should have called lookup", function() {
		expect(ArRequestRepository.lookup).toHaveBeenCalledWith(saved_rec);
	    });

	    it("should call lookup once only", function() {
		expect(lookupSpy.callCount).toEqual(1);
	    });

	    it("should throw an ArCookie", function() {
		expect(Object.getOwnPropertyNames(saved_err)).toContain('addListener');
	    });

	    it("should call the right URL", function() {
		expect(request.url).
		    toEqual("http://localhost/raptor/json/cached/queues/65/calls/176");
	    });

	    describe("second access", function() {
		var saved_err2;

		beforeEach(function() {
		    try {
			new_q.value.rec;
		    } catch (err) {
			saved_err2 = err;
		    }
		});

		it("should still throw an exception", function() {
		    expect(Object.getOwnPropertyNames(saved_err2)).toContain('addListener');
		});

		it("should not call AJAX a 2nd time", function() {
		    expect(getTransportSpy.callCount).toEqual(1);
		});
	    });

	    describe("listeners can be added", function() {
		var listenerSpy;

		beforeEach(function() {
		    listenerSpy = jasmine.createSpy();
		    saved_err.addListener(listenerSpy);
		});

		it("should not be called yet", function() {
		    expect(listenerSpy).not.toHaveBeenCalled();
		});

		describe("when response comes", function() {
		    beforeEach(function() {
			spyOn(Ar, "register").andCallThrough();
			request.response(TestResponses[request.url]);
		    });

		    it("should cause listener to have been called", function() {
			expect(listenerSpy).toHaveBeenCalled();
		    });

		    it("should cause Ar.register to be called", function() {
			expect(Ar.register).toHaveBeenCalled();
		    });

		    it("should set property to new record", function() {
			expect(new_q.value.rec.id).toEqual(176);
		    });
		});
	    });
	});
    });

    describe("AJAX call for has_many", function() {
	var saved_recs;
	var new_q;

	beforeEach(function() {
	    Ar.clearRepository();
	    ArRequestRepository.clearRepository();

	    saved_recs = new SpecHasManyCachedCall();
	    q = {
		id: Math.floor(Math.random() * 10000),
		ar_objects: {
		    recs: saved_recs
		}
	    };

	    new_q = Ar.register('blah', q);
	    spyOn(ArRequestRepository, "lookup").andCallThrough();
	});

	it("should not fire when registering", function() {
	    expect(Ajax.getTransport).not.toHaveBeenCalled();
	});

	it("should not have called lookup", function() {
	    expect(ArRequestRepository.lookup).not.toHaveBeenCalled();
	});

	describe("accessing the record", function() {
	    var request;
	    var saved_err;

	    beforeEach(function() {
		// Accessing recs will throw an ArCookie
		try {
		    new_q.value.recs;
		} catch (err) {
		    saved_err = err;
		}
		request = mostRecentAjaxRequest();
	    });

	    it("should fire when record is accessed", function() {
		expect(Ajax.getTransport).toHaveBeenCalled();
	    });

	    it("should have called lookup", function() {
		expect(ArRequestRepository.lookup).toHaveBeenCalledWith(saved_recs);
	    });

	    it("should throw an ArCookie", function() {
		expect(Object.getOwnPropertyNames(saved_err)).toContain('addListener');
	    });

	    it("should call the right URL", function() {
		expect(request.url).
		    toEqual("http://localhost/raptor/json/cached/queues/65/calls");
	    });

	    describe("when response comes", function() {
		var registerSpy;

		beforeEach(function() {
		    registerSpy = spyOn(Ar, "register").andCallThrough();
		    request.response(TestResponses[request.url]);
		});

		it("should cause Ar.register to be called", function() {
		    expect(registerSpy.callCount).toEqual(9);
		});

		it("should set property to an array of the new records", function() {
		    expect(new_q.value.recs).isInstanceOf(Array);
		});

		it("should have 9 elements", function() {
		    expect(new_q.value.recs.length).toEqual(9);
		});

		it("should have id of 163 in the 2nd element", function() {
		    expect(new_q.value.recs[1].id).toEqual(163);
		});
	    });
	});
    });

    describe("register with element already attached", function() {
	var getTransportSpy;
	var lookupSpy;
	var new_q;
	var saved_rec;

	beforeEach(function() {
	    Ar.clearRepository();
	    ArRequestRepository.clearRepository();

	    getTransportSpy = Ajax.getTransport;

	    q = {
		id: Math.floor(Math.random() * 10000),
		rec : {
		    id: 65,
		    banana: "good"
		},
		ar_objects: {
		    rec: {
			"class_name":"Cached::Queue",
			"association_type":"belongs_to",
			"id":65,
			"url":"/raptor/json/cached/queues/65"},
		    }
	    };

	    new_q = Ar.register('blah', q);
	    lookupSpy = spyOn(ArRequestRepository, "lookup").andCallThrough();
	});

	it("should return rec already", function() {
	    /* In case you don't believe this is working... uncomment this */
	    /* console.log(new_q.value.rec); */
	    expect(new_q.value.rec.id).toEqual(65);
	});

	it("should not have called AJAX", function() {
	    expect(getTransportSpy).not.toHaveBeenCalled();
	});
    });
});
