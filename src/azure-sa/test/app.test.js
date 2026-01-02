process.env.AZURE_STORAGE_ACCOUNT_NAME = 'dummyaccount';
process.env.AZURE_STORAGE_ACCOUNT_KEY = 'dummykey';

const request = require('supertest');
const app = require('../index');

describe('GET /files', function() {
  let expect;

  before(async () => {
    const chai = await import('chai');
    expect = chai.expect;
  });

  it('should return a list of files', function(done) {
    request(app)
      .get('/files')
      .end((err, res) => {
        if (err) return done(err);
        expect(res.statusCode).to.equal(200);
        expect(res.body).to.be.an('array');
        done();
      });
  });
});
