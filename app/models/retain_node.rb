# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# === Retain Node
#
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
# Retain the phrase "I think" needs to be sprinkled liberally about.)
#
# But in addition to the hardware or softare and test or normal
# flavors, a node can have some backup ports or alternate ports.  This
# seems especially true with the test nodes.  Raptor users the term
# "Retain Node" to talk about a particular port on a particular node
# -- so, in a sense, it is more restrictive.
#
# ==Fields
#
# <em>host - string</em>::
#   A fully qualified hostname or it could be an IPv4 address I
#   suppose.
#
# <em>node - string</em>::
#   The name of the node. e.g. RTA or BDC
#
# <em>type - string</em>::
#   Either "software" or "hardware"
#
# <em>description - string</em>::
#   A somewhat pretty descript of this tuple.  Usually seen only by
#   Raptor admins.
#
# <em>port - integer</em>::
#   The IP port
#
# <em>apptest - boolean</em>::
#   True if this is goes to an APPTEST server.  False if it goes to a
#   production server.
#
# <em>tunnel_offset - integer</em>::
#   At the current time, Raptor can tunnel back and forth via ssh
#   tunnels.  The config/initializers/retain.rb file will look for a
#   host specific file to load from the config directory (the host
#   that Raptor is running on) e.g. config/tcp237.rb.  That file can
#   set Retain::TUNNELLED to true and also specify
#   Retain::BASE_PORT. <em>tunnel_offset</em> plus the BASE_PORT will
#   be used when TUNNELLED is true.  (The host will be localhost in
#   that case).
#
# <em>timestamps - date time without timezone</em>::
#   The usual Rails created_at and updated_at timestamps.
#
class RetainNode < ActiveRecord::Base
  # :attr: id
  # The key to the database table.

  # :attr: host
  # A fully qualified hostname or it could be an IPv4 address I
  # suppose.
  
  # :attr: node
  # The name of the node: e.g. RTA or BDC

  # :attr: node_type
  # Either "software" or "hardware"

  # :attr: description
  # A pretty name for this node.

  # :attr: port
  # The port (as in tcp/ip port) to connect to.

  # :attr: apptest
  # A boolean which is true if this node is part of APPTEST (used for
  # testing).

  # :attr: tunnel_offset
  # When Raptor is behind a firewall, a sequence of punch throughs are
  # created via ssh starting at a particular port.  The starting port
  # is specified in config/<hostname>.rb file e.g. config/tcp237.rb.
  # The tunnel_offset is added to the base port to determine the port
  # to connect to on the local host.  There is a script make-to-lab
  # which spits out the to-lab script which is used to ssh from a host
  # on the outside of the firewall to the host on the inside of the
  # firewall.

  ##
  # :attr: created_at
  # Rails normal created_at timestamp that is when the db record was
  # created.

  ##
  # :attr: updated_at
  # Rails normal updated_at timestamp.  Each time the db record is
  # saved, this gets updated.

  ##
  # :attr: retain_node_selectors
  # A has_many assocation to the RetainNodeSelector that specify this
  # RetainNode.
  has_many :retain_node_selectors
end
