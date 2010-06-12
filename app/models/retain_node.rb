# -*- coding: utf-8 -*-

# = Retain Node
# The model used to denote a Retain node.  I'm misusing the term for
# the sake of clarity (and I have some property in Florida).  The true
# definition of a Retain Node is something like RTA or BDC.  They come
# in different flavors and the flavors seem to often have pairs.
#
# First, there are hardware and software nodes.  PMRs reside on
# software nodes while PMHs reside on hardware nodes.  Second, there
# are normal nodes for production work and also test nodes for testing
# software.  The test nodes, collectively, are known as APPTEST (I
# think -- which goes without saying... any time I'm talking about
# Retain the phrase "I think" needs to be sprinkled liberally about.
#
# But in addition to the hardware or softare and test or normal
# flavors, a node can have some backup ports or alternate ports.  This
# seems especially true with the test nodes.  Raptor users the term
# "Retain Node" to talk about a particular port on a particular node
# -- so, in a sense, it is more restrictive.
#
# ==Fields
#
# <em>host - string</em>:: A fully qualified hostname or it could be
#   an IPv4 address I suppose.
#
# <em>node - string</em>:: The name of the node. e.g. RTA or BDC
#
# <em>type - string</em>:: Either "software" or "hardware"
#
# <em>description - string</em>:: A somewhat pretty descript of this
#   tuple.  Usually seen only by Raptor admins.
#
# <em>port - integer</em>:: The IP port
#
# <em>apptest - boolean</em>:: True if this is goes to an APPTEST
#   server.  False if it goes to a production server.
#
# <em>tunnel_offset - integer</em>:: At the current time, Raptor can
#   tunnel back and forth via ssh tunnels.  The
#   config/initializers/retain.rb file will look for a host specific
#   file to load from the config directory (the host that Raptor is
#   running on) e.g. config/tcp237.rb.  That file can set
#   Retain::TUNNELLED to true and also specify Retain::BASE_PORT.
#   <em>tunnel_offset</em> plus the BASE_PORT will be used when
#   TUNNELLED is true.  (The host will be localhost in that case).
#
# <em>timestamps - date time without timezone</em>:: The usual Rails
#   created_at and updated_at timestamps.
#
class RetainNode < ActiveRecord::Base
  has_many :retain_node_selectors
end
