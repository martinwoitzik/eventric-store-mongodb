chai      = require 'chai'
expect    = chai.expect
sinon     = require 'sinon'
sandbox   = sinon.sandbox.create()
sinonChai = require 'sinon-chai'
chai.use sinonChai

MongoClient = require('mongodb').MongoClient

describe 'MongoDB Store Adapter', ->
  mongoDbStore = null

  before ->
    mongoDbStore = require './mongodb_store'


  afterEach ->
    sandbox.restore()


  describe 'given we got a mongo.dbInstance', ->
    describe '#initialize', ->
      it 'should not call MongoClient.connect', (done) ->
        sandbox.spy MongoClient, 'connect'
        options =
          dbInstance: sandbox.stub()
        mongoDbStore.initialize options, ->
          expect(MongoClient.connect).to.not.have.been.called
          done()


  describe 'given we got no mongo.dbInstance', ->

    before (done) ->
      options =
        database: '__eventric_tests'
      sandbox.spy MongoClient, 'connect'
      mongoDbStore.initialize options, (err) ->
        done()


    after ->
      mongoDbStore.db.close()


    describe '#initialize', ->
      it 'should call the MongoClient.connect with the correct options', ->

        expect(MongoClient.connect).to.have.been.calledWith 'mongodb://127.0.0.1:27017/__eventric_tests'


    describe '#save', ->
      it 'should save the given doc', (done) ->
        doc =
          wat: 'ever'
        mongoDbStore.save 'someCollection', doc, (err, docs) ->
          expect(err).to.be.null
          expect(docs[0]._id).to.be.ok
          done()


    describe '#find', ->
      it 'should find the previously saved doc', (done) ->
        doc =
          wat: 'ever'
        mongoDbStore.save 'someCollection', doc, (err, savedDocs) ->
          mongoDbStore.find 'someCollection', {_id: savedDocs[0]._id}, (err, docs) ->
            expect(docs).to.deep.equal [
              savedDocs[0]
            ]
            done()
