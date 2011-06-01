
SpecBelongsToArObject = function() {
    this.id = Math.floor(Math.random() * 10000);
    this.association_type = "belongs_to";
    this.class_name = "Something::Differnt";
    this.magic = "ActiveRecord";
    this.url = "/someplace/like/this";
};

SpecBelongsToCachedCall = function() {
    this.id = 176;
    this.association_type = "belongs_to";
    this.class_name = "Cached::Call";
    this.magic = "ActiveRecord";
    this.url = "http://localhost/raptor/json/cached/queues/65/calls/176";
};

SpecBelongsToCachedCallWithElement = function() {
    this.id = 176;
    this.association_type = "belongs_to";
    this.class_name = "Cached::Call";
    this.magic = "ActiveRecord";
    this.url = "http://localhost/raptor/json/cached/queues/65/calls/176";
    this.element = {"call":{"call_control_flag_1":65,"category":"XSR","comments":"2nd TC on tcaustin may26                              ","contact_phone_1":"32 498946103       ","contact_phone_2":"+32(0)2.206.33.01  ","created_at":"2011-05-28T14:22:35Z","cstatus":"R      ","customer_time_zone_adj":120,"dirty":false,"dispatched_employee":"305356","id":176,"last_fetched":"2011-05-28T14:22:36Z","next_queue_css":"normal","next_queue_editable":false,"next_queue_message":"Next Queue for WT not editable or judged","nls_contact_name":"Christophe Buyck            ","nls_customer_name":"ELECTRABEL MIDFRAME CENTER  ","owner_css":"normal","owner_editable":false,"owner_message":"Owner for WT not editable or judged","p_s_b":"P","pmr_id":227,"ppg":"102","priority":1,"queue_id":65,"resolver_css":"good","resolver_editable":true,"resolver_message":"PMR Resolver is Queue Owner","severity":1,"slot":1,"system_down":false,"time_zone_code":60,"updated_at":"2011-05-28T22:34:16Z"}};
};

SpecHasManyCachedCall = function() {
    this.association_type = "has_many";
    this.class_name = "Cached::Call";
    this.magic = "ActiveRecord";
    this.url = "http://localhost/raptor/json/cached/queues/65/calls";
};

beforeEach(function () {
    this.addMatchers({
	isInstanceOf: function (obj) { return this.actual instanceof obj; }
    });
});
