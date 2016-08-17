var lg = require('bulk_labeler/label_generator')
describe("frontBackLabeler", function() {

  it("just counts up from 1 by default", function() {

    var gen = lg.pageLabelGenerator();

    expect(gen.next().value).toEqual("1");
    expect(gen.next().value).toEqual("2");
    expect(gen.next().value).toEqual("3");
  });

  it("can be given a null number", function() {
    var start = "",
        method = "paginate",
        frontLabel = "",
        backLabel = "",
        startWith = "",
        unitLabel = "Page",
        bracket = false;

    var gen = lg.pageLabelGenerator(start, method, frontLabel, backLabel,
      startWith, unitLabel, bracket)

    expect(gen.next().value).toEqual("Page");
  });

  it("brackets", function() {
    var start = 1,
        method = "paginate",
        frontLabel = "",
        backLabel = "",
        startWith = "",
        unitLabel = "",
        bracket = true;

    var gen = lg.pageLabelGenerator(start, method, frontLabel, backLabel,
      startWith, unitLabel, bracket)

    expect(gen.next().value).toEqual("[1]");
    expect(gen.next().value).toEqual("[2]");
    expect(gen.next().value).toEqual("[3]");
  });

  it("takes a unitLabel", function() {
    var start = 1,
        method = "paginate",
        frontLabel = "",
        backLabel = "",
        startWith = "",
        unitLabel = "p. ",
        bracket = false;

    var gen = lg.pageLabelGenerator(start, method, frontLabel, backLabel,
      startWith, unitLabel, bracket)

    expect(gen.next().value).toEqual("p. 1");
    expect(gen.next().value).toEqual("p. 2");
    expect(gen.next().value).toEqual("p. 3");
  });

  it("foliates with the correct front and back labels", function() {
    var start = 1,
        method = "foliate",
        frontLabel = "r",
        backLabel = "v",
        startWith = "front",
        unitLabel = "",
        bracket = false;

    var gen = lg.pageLabelGenerator(start, method, frontLabel, backLabel,
      startWith, unitLabel, bracket)

    expect(gen.next().value).toEqual("1r");
    expect(gen.next().value).toEqual("1v");
    expect(gen.next().value).toEqual("2r");
    expect(gen.next().value).toEqual("2v");
  });

  it("foliates starting with the back with the correct front and back labels", function() {
    var start = 1,
        method = "foliate",
        frontLabel = "r",
        backLabel = "v",
        startWith = "back",
        unitLabel = "",
        bracket = false;

    var gen = lg.pageLabelGenerator(start, method, frontLabel, backLabel,
      startWith, unitLabel, bracket)

    expect(gen.next().value).toEqual("1v");
    expect(gen.next().value).toEqual("2r");
    expect(gen.next().value).toEqual("2v");
    expect(gen.next().value).toEqual("3r");
    expect(gen.next().value).toEqual("3v");
  });

  it("respects changes to everything", function() {
    var start = 'vi',
        method = "foliate",
        frontLabel = " (recto)",
        backLabel = " (verso)",
        startWith = "back",
        unitLabel = "f. ",
        bracket = true;

    var gen = lg.pageLabelGenerator(start, method, frontLabel, backLabel,
      startWith, unitLabel, bracket)

    expect(gen.next().value).toEqual("[f. vi (verso)]");
    expect(gen.next().value).toEqual("[f. vii (recto)]");
    expect(gen.next().value).toEqual("[f. vii (verso)]");
  });
});

describe("frontBackLabeler", function() {

  it("alternates between the given values", function() {
    var frontLabel = "r",
        backLabel = "v",
        labeler = lg.frontBackLabeler(frontLabel, backLabel);

    expect(labeler.next().value).toEqual(frontLabel);
    expect(labeler.next().value).toEqual(backLabel);
    expect(labeler.next().value).toEqual(frontLabel);
  });

  it("can start with the back", function() {
    var frontLabel = "r",
        backLabel = "v",
        labeler = lg.frontBackLabeler(frontLabel, backLabel, "back");

    expect(labeler.next().value).toEqual(backLabel);
    expect(labeler.next().value).toEqual(frontLabel);
    expect(labeler.next().value).toEqual(backLabel);
  });

  it("is OK with null as a label", function() {
    var frontLabel = null,
        backLabel = "v",
        labeler = lg.frontBackLabeler(null, backLabel);

    expect(labeler.next().value).toEqual(frontLabel);
    expect(labeler.next().value).toEqual(backLabel);
    expect(labeler.next().value).toEqual(frontLabel);
  });

});

describe("pageNumberGenerator", function() {

  it("paginates with integers starting from 1 by default", function() {
    var gen = lg.pageNumberGenerator();
    expect(gen.next().value).toEqual(1);
    expect(gen.next().value).toEqual(2);
    expect(gen.next().value).toEqual(3);
  });

  it("can paginate starting with other integers", function() {
    var gen = lg.pageNumberGenerator(5);
    expect(gen.next().value).toEqual(5);
    expect(gen.next().value).toEqual(6);
    expect(gen.next().value).toEqual(7);
  });

  it("will paginate with roman numerals", function() {
    var gen = lg.pageNumberGenerator('i');
    expect(gen.next().value).toEqual('i');
    expect(gen.next().value).toEqual('ii');
    expect(gen.next().value).toEqual('iii');
  });

  it("will paginate with roman numerals starting from other than 'i'", function() {
    var gen = lg.pageNumberGenerator('xlii');
    expect(gen.next().value).toEqual('xlii');
    expect(gen.next().value).toEqual('xliii');
    expect(gen.next().value).toEqual('xliv');
    expect(gen.next().value).toEqual('xlv');
  });

  it("will foliate", function() {
    var gen = lg.pageNumberGenerator(1, "foliate");
    expect(gen.next().value).toEqual(1);
    expect(gen.next().value).toEqual(1);
    expect(gen.next().value).toEqual(2);
    expect(gen.next().value).toEqual(2);
  });

  it("will foliate starting with the back", function() {
    var gen = lg.pageNumberGenerator(1, "foliate", "back");
    expect(gen.next().value).toEqual(1);
    expect(gen.next().value).toEqual(2);
    expect(gen.next().value).toEqual(2);
    expect(gen.next().value).toEqual(3);
    expect(gen.next().value).toEqual(3);
  });

  it("will foliate with roman numerals", function() {
    var gen = lg.pageNumberGenerator('i', "foliate");
    expect(gen.next().value).toEqual('i');
    expect(gen.next().value).toEqual('i');
    expect(gen.next().value).toEqual('ii');
    expect(gen.next().value).toEqual('ii');
  });

  it("will foliate with roman numerals starting with the back", function() {
    var gen = lg.pageNumberGenerator('i', "foliate", "back");
    expect(gen.next().value).toEqual('i');
    expect(gen.next().value).toEqual('ii');
    expect(gen.next().value).toEqual('ii');
    expect(gen.next().value).toEqual('iii');
    expect(gen.next().value).toEqual('iii');
  });

 it("will foliate starting with any number", function() {
   var gen = lg.pageNumberGenerator(42, "foliate");
   expect(gen.next().value).toEqual(42);
   expect(gen.next().value).toEqual(42);
   expect(gen.next().value).toEqual(43);
   expect(gen.next().value).toEqual(43);
 });

 it("will foliate starting with any number starting with the back", function() {
   var gen = lg.pageNumberGenerator(42, "foliate", "back");
   expect(gen.next().value).toEqual(42);
   expect(gen.next().value).toEqual(43);
   expect(gen.next().value).toEqual(43);
   expect(gen.next().value).toEqual(44);
   expect(gen.next().value).toEqual(44);
 });

 it("will foliate starting with any roman numeral", function() {
   var gen = lg.pageNumberGenerator('xlii', "foliate");
   expect(gen.next().value).toEqual('xlii');
   expect(gen.next().value).toEqual('xlii');
   expect(gen.next().value).toEqual('xliii');
   expect(gen.next().value).toEqual('xliii');
 });

 it("will foliate starting with any roman numeral starting with the back", function() {
   var gen = lg.pageNumberGenerator('xlii', "foliate", "back");
   expect(gen.next().value).toEqual('xlii');
   expect(gen.next().value).toEqual('xliii');
   expect(gen.next().value).toEqual('xliii');
   expect(gen.next().value).toEqual('xliv');
   expect(gen.next().value).toEqual('xliv');
 });

 it("respects case for roman numerals", function() {
   var gen = lg.pageNumberGenerator('V');
   expect(gen.next().value).toEqual('V');
   expect(gen.next().value).toEqual('VI');
   expect(gen.next().value).toEqual('VII');
 });
});

describe("romanize", function() {

  it("seems to work", function() {
    expect(lg.romanize(1)).toEqual('i');
    expect(lg.romanize(42)).toEqual('xlii');
    expect(lg.romanize(100)).toEqual('c');
  });

});

describe("deromanize", function() {

  it("seems to work", function() {
    expect(lg.deromanize('i')).toEqual(1);
    expect(lg.deromanize('xlii')).toEqual(42);
    expect(lg.deromanize('c')).toEqual(100);
  });

});
