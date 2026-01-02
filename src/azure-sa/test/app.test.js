const request = require('supertest');
const { expect } = require('chai');
const app = require('../index');

describe('GET /files', function() {
  it('should return a list of files', function(done) {
    request(app)
      .get('/files')
      .end((err, res) => {
        expect(res.statusCode).to.equal(200);
        expect(res.body).to.be.an('array');
        done();
      });
  });
});
