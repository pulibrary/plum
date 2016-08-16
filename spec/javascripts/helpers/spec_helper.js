//= require jquery
//= require jasmine-jquery
// rake spec:javascript loads specs relative to the tmp/jasmine/runner.html, need
// to override:
jasmine.getFixtures().fixturesPath="../../spec/javascripts/fixtures"
