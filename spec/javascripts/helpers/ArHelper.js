
SpecBelongsToArObject = function() {
    this.id = Math.floor(Math.random() * 10000);
    this.association_type = "belongs_to";
    this.class_name = "Something::Differnt";
    this.url = "/someplace/like/this";
};

SpecBelongsToCachedCall = function() {
    this.id = 176;
    this.association_type = "belongs_to";
    this.class_name = "Cached::Call";
    this.url = "http://localhost/raptor/json/cached/queues/65/calls/176";
};

SpecHasManyCachedCall = function() {
    this.association_type = "has_many";
    this.class_name = "Cached::Call";
    this.url = "http://localhost/raptor/json/cached/queues/65/calls";
};

beforeEach(function () {
    this.addMatchers({
	isInstanceOf: function (obj) { return this.actual instanceof obj; }
    });
});
