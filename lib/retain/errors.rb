# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  ##
  # Array that maps Retain error codes to the text that the
  # documentation says the code represents.
  Errors = Array.new
  Errors[   1] = "Indicates that the \"SDIYSHDR\" eye catcher in the
                  request system header was not correct when received
                  by the function router (SDICRECV)."
  Errors[   2] = "Indicates that the inbound system header return code
                  (SDIRC) wasn't correctly initialized with zeros."
  Errors[   3] = "Indicates that the buffer received from the external
                  system is less than the length of the system header,
                  SDIYSHDR, or greater than the maximum allowed of
                  16K."
  Errors[   4] = "Indicates that the data received from the external
                  system was less than the length of the system
                  header, SDIYSHDR (80 bytes)."
  Errors[   5] = "Indicates that the number of data elements received
                  is less than one."
  Errors[   6] = "Indicates that the interface program level received
                  is incorrect, that is, it is not the current level."
  Errors[   7] = "Indicates that the request type is blank or binary
                  zeros."
  Errors[   8] = "Indicates that the input data flag was received with
                  incorrect status. Flag expected to be marked input
                  data but was set to indicate output data."
  Errors[   9] = "Indicates that the request type received from the
                  external system was not found listed in the
                  program's internal table of defined request types."
  Errors[  10] = "Indicates that the data security classification
                  received was not unclassified (U), IBM internal use
                  only (I), or IBM confidential (C)."
  Errors[  11] = "Indicates that there was a VTAM communication
                  error."
  Errors[  12] = "Indicates that the requestor type from the external
                  system is unknown. It must be either \"C\" for IBM
                  customer or \"I\" for IBM internal person."
  Errors[  13] = "Indicates that the requestor of service is not an
                  IBM customer or IBM internal person."
  Errors[  20] = "Indicates that the SDI interface application has not
                  completed its initialization process."
  Errors[  26] = "Indicates that the billing ID from the external
                  system was not found listed in the program's
                  internal table of billing Id's."
  Errors[  98] = "Indicates that DIAXBMSG experienced an error trying
                  to build a message."
  Errors[  99] = "Indicates that an ABEND has occurred in the function
                  router."
  Errors[ 200] = "Indicates that the application program received an
                  invalid data element type."
  Errors[ 201] = "Indicates that the application program received a
                  data element with an incorrect length."
  Errors[ 202] = "Indicates that the application program detected a
                  difference between the number of data elements
                  processed and number of data elements passed in the
                  application header."
  Errors[ 203] = "Indicates that the application program detected a
                  difference between the total length of the elements
                  processed and the total length passed in the
                  application header."
  Errors[ 204] = "Indicates that the number of data elements received
                  is less than zero or requests which require paired
                  elements have an element missing or a required data
                  element is missing."
  Errors[ 205] = "Indicates that a COMMAREA error was detected."
  Errors[ 206] = "Indicates that the \"SDIYAHDR\" eye catcher in the
                  application header was not correct when received by
                  the application."
  Errors[ 207] = "Indicates that a duplicate data element was received
                  by the application."
  Errors[ 208] = "Indicates that the content of a data element
                  received by the application was incorrect, that is,
                  not as expected."
  Errors[ 208] = "Indicates that the content of a data element
                  received by the application was incorrect, that is,
                  not as expected."
  Errors[ 209] = "Indicates that the specified Queue and Center are
                  not valid on this system."
  Errors[ 216] = "Indicates a library last item error."
  Errors[ 217] = "Indicates a library duplicate item error."
  Errors[ 218] = "Indicates a library no file error."
  Errors[ 223] = "Indicates that too many words were in the search
                  argument."
  Errors[ 224] = "Indicates that too many characters were in the
                  search argument."
  Errors[ 225] = "Indicates that a logical operator follows the last
                  word in the search argument."
  Errors[ 226] = "Indicates that a logical operator precedes the first
                  argument in the search argument."
  Errors[ 227] = "Indicates that there was no search argument."
  Errors[ 228] = "Indicates that a word was too short in the search
                  argument."
  Errors[ 229] = "Indicates that an error was encountered when
                  transforming the search argument to either uppercase
                  or to Japanese."
  Errors[ 230] = "Indicates that a library CCSID error."
  Errors[ 232] = "Indicates mismatched input CCSIDs among data fields
                  that share a CCSID on page 0 of a Problem Management
                  record."
  Errors[ 233] = "Indicates an NLS data transformation error in
                  Problem Management."
  Errors[ 250] = "Indicates the CDBM interface could not be opened."
  Errors[ 251] = "Indicates that a CDBM read record operation had a
                  problem."
  Errors[ 252] = "Indicates that a CDBM write record operation had a
                  problem."
  Errors[ 253] = "Indicates that a CDBM delete record operation had a
                  problem."
  Errors[ 254] = "Indicates that a CDBM control operation had a
                  problem."
  Errors[ 255] = "CDBM data base is temporarily unavailable, such as a
                  record is locked."
  Errors[ 256] = "The CDBM record could not be found."
  Errors[ 256] = "The CDBM record could not be found."
  Errors[ 257] = "The PMQM record is full. The requested LUID can not
                  be monitored."
  Errors[ 258] = "The LUID could not be found"
  Errors[ 259] = "The requested LUID is already be monitored by the
                  specified center and queue."
  Errors[ 300] = "Indicates that the the pointer to the CICS CWA could
                  not be setup correctly."
  Errors[ 301] = "Indicates that an attempt to obtain CICS dynamic
                  storage failed."
  Errors[ 302] = "Indicates that a read operation of a CICS temporary
                  storage queue failed."
  Errors[ 303] = "Indicates that a write operation to a CICS temporary
                  storage queue failed."
  Errors[ 305] = "Indicates that a LINK to a CICS program failed."
  Errors[ 306] = "Indicates that a delete queue operation of a CICS
                  temporary storage queue failed."
  Errors[ 307] = "Indicates that a CICS error occurred reading a TDQ."
  Errors[ 308] = "Indicates that a CICS error occurred trying to start
                  a transaction."
  Errors[ 309] = "Indicates that a CICS error occurred trying to
                  retrieve a data area."
  Errors[ 311] = "Indicates that a CICS TDQ write error occurred."
  Errors[ 315] = "Indicates that SDI_SECURITY contained something
                  other than and U, I, or C."
  Errors[ 316] = "Indicates a CHAN file error."
  Errors[ 317] = "Indicates a POC Command Table error in SPR2 file."
  Errors[ 319] = "Indicates a valid DE not handled in the code."
  Errors[ 320] = "Create service failed."
  Errors[ 321] = "PMR not queued, try later."
  Errors[ 322] = "Indicates a bad return code was received from
                  SDSPMRR or other service."
  Errors[ 350] = "Indicates that a CICS ABEND has occurred."
  Errors[ 351] = "Indicates that a PL/I ABEND has occurred."
  Errors[ 352] = "Indicates that a forced (ATCH) ABEND was initiated
                  by Operations."
  Errors[ 353] = "Indicates that a CICS resource ABEND (AEY9 or ASP7)
                  has occurred."
  Errors[ 355] = "Indicates a bad return code was received from
                  another program that was linked to."
  Errors[ 356] = "Indicates an invalid number of data items passed."
  Errors[ 399] = "Indicates that at least one document out of many
                  cannot be found. Returned data may be truncated."
  Errors[ 400] = "Indicates that DIAXBMSG experienced an error trying
                  to build a message."
  Errors[ 401] = "Indicates that common retrieval service had an error
                  trying to retrieve data for an APAR or PTF."
  Errors[ 402] = "Indicates that common retrieval service had an error
                  trying to retrieve data for an upgrade or subset
                  (PSP)."
  Errors[ 402] = "Indicates that common retrieval service had an error
                  trying to retrieve data for an upgrade or subset
                  (PSP)."
  Errors[ 403] = "Indicates that build list service had an error
                  trying to retrieve some data (component ID, release,
                  status, closing code) for PTF validation."
  Errors[ 404] = "Indicates that document formatting service had an
                  error trying to format a document."
  Errors[ 405] = "Indicates that an error occurred trying to do an
                  IRIS search."
  Errors[ 406] = "IRIS search had a work area overflow because the
                  search argument was too broad.  This is a user
                  error, and it is not logged."
  Errors[ 407] = "SDS validation service failure."
  Errors[ 408] = "DAF validation service failure."
  Errors[ 409] = "CCPF common retrieval service failure."
  Errors[ 410] = "PMR retrieval service failure."
  Errors[ 411] = "SDI sender service failure."
  Errors[ 412] = "SDS services error with DIFQ."
  Errors[ 413] = "IRIS file list service failure."
  Errors[ 414] = "PMR create and update services failure."
  Errors[ 415] = "No APAR found."
  Errors[ 500] = "Indicates that a data type could not be found in SSF
                  table by common retrieval service. "
  Errors[ 501] = "Indicates that an invalid symbol (file/symbol) was
                  passed to common retrieval service so symbol was not
                  found in CHAN file."
  Errors[ 502] = "Indicates that a requested document is not
                  available, either because it is truly not in the
                  data base or it is IBM Confidential. See APAR
                  BL05633 for information on this return code."
  Errors[ 502] = "In the case of an UPGRADE request, the document is
                  not available, because it is not in the data base or
                  is confidential. Note: No ETRK record is generated.
                  In the case of a SUBSET request, the document is not
                  available, because of an error in key fields of the
                  data base. Note: A 170 ETRK record is generated."
  Errors[ 502] = "The PCQC and PMQM record for the requested center
                  and queue can not be found. The queue monitor LUID
                  service could not be performed."
  Errors[ 502] = "Indicates that a requested document is not available
                  because it is not in the data base."
  Errors[ 503] = "Data link retrieval service failure."
  Errors[ 504] = "Data link retrieval is not authorized."
  Errors[ 505] = "Data link retrieval record count is too big."
  Errors[ 506] = "Data link retrieval restart ID error."
  Errors[ 507] = "Data link retrieval empty record."
  Errors[ 508] = "DAF validation input unknown or not found."
  Errors[ 509] = "Submission/subscription SUB/SUB error was detected."
  Errors[ 510] = "Customer# not found in Customer Profile Facility."
  Errors[ 511] = "Avante synonym table not available."
  Errors[ 512] = "Search argument exceeded 124 characters."
  Errors[ 513] = "Error returned from IMRS."
  Errors[ 514] = "Error returned from AVABDFE"
  Errors[ 515] = "Error returned from AVAZNQUE"
  Errors[ 516] = "An service program detected an error"
  Errors[ 517] = "VSAM read error"
  Errors[ 518] = "VSAM write error"
  Errors[ 519] = "VSAM rewrite error"
  Errors[ 520] = "VSAM delete error"
  Errors[ 521] = "Search argument exceeds 254 characters."
  Errors[ 522] = "No compids for input PID#"
  Errors[ 523] = "A SYSID related error was detected"
  Errors[ 524] = "Validation failed within Problem Management"
  Errors[ 526] = "Indicates a non-zero return code from SIS tracking
                  (SDSSIST)."
  Errors[ 602] = "PMR create and update services failure, conditional
                  unsuccessful."
  Errors[ 603] = "PMR create and update services failure, input
                  control field error."
  Errors[ 604] = "PMR create and update services failure, input data
                  error."
  Errors[ 605] = "PMR create and update services failure, invalid
                  request type."
  Errors[ 606] = "PMR create and update services failure, I/O error."
  Errors[ 607] = "PMR create and update services failure, queue
                  selection error."
  Errors[ 608] = "PMR create and update services failure, internal
                  PMGT error."
  Errors[ 609] = "PMR create and update services failure, Queue
                  Manager internal error."
  Errors[ 610] = "PMR create and update services failure, record is
                  locked."
  Errors[ 611] = "PMR create and update services failure, remote files
                  are unavailable."
  Errors[ 612] = "PMR create and update services failure, maximum
                  pages exceeded."
  Errors[ 613] = "PMR create and update services failure, queue
                  error."
  Errors[ 614] = "PMR create and update services failure, queue
                  error."
  Errors[ 615] = "PMR create and update services failure, branch
                  office does not exist."
  Errors[ 616] = "PMR create and update services failure, branch
                  office record could not be created."
  Errors[ 699] = "PMR create and update services failure, program
                  check abend."
  Errors[ 700] = "Indicates an error ocurred when calling a retain
                  subroutine."
  Errors[ 701] = "Indicates a sort error."
  Errors[ 702] = "User not allowed to search that library."
  Errors[ 703] = "Indicates user supplied invalid password."
  Errors[ 704] = "Symbol could not be found in file."
  Errors[ 705] = "Indicates that the user's password has expired."
  Errors[ 706] = "Indicates that too many input DE14s were passed."
  Errors[ 707] = "Invalid error type was passed."
  Errors[ 708] = "Monitoring has been shutdown for specified LUID,
                  Queue and Center."
  Errors[ 901] = "PSCA input and output symbols not equal. Found in
                  routine SDIVDA0."
  Errors[ 902] = "Customer ID not found in CCPF."
  Errors[ 903] = "No PID#s found for customer."
  Errors[ 904] = "User not authorized for document."
  Errors.map! do |t|
    t.gsub("\n", ' ').gsub(/  +/, ' ') unless t.nil?
  end
end
