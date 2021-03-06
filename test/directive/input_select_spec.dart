library input_select_spec;

import '../_specs.dart';

//TODO(misko): re-enabled dissabled tests once we have forms.

main() {
  describe('input-select', () {

    describe('ng-value', () {
      TestBed _;
      beforeEach(inject((TestBed tb) => _ = tb));

      it('should retrieve using ng-value', () {
        _.compile(
            '<select ng-model="robot" probe="p">'
            '<option ng-repeat="r in robots" ng-value="r">{{r.name}}</option>'
            '</select>');
        var r2d2 = { "name":"r2d2"};
        var c3p0 = {"name":"c3p0"};
        _.rootScope.robots = [ r2d2, c3p0 ];
        _.rootScope.$digest();
        _.selectOption(_.rootElement, 'c3p0');
        expect(_.rootScope.robot).toEqual(c3p0);

        _.rootScope.robot = r2d2;
        _.rootScope.$digest();
        expect(_.rootScope.robot).toEqual(r2d2);
        expect(_.rootElement).toEqualSelect([['r2d2'], 'c3p0']);
      });

      it('should retrieve using ng-value', () {
        _.compile(
            '<select ng-model="robot" probe="p" multiple>'
            '<option ng-repeat="r in robots" ng-value="r">{{r.name}}</option>'
            '</select>');
        var r2d2 = { "name":"r2d2"};
        var c3p0 = {"name":"c3p0"};
        _.rootScope.robots = [ r2d2, c3p0 ];
        _.rootScope.$digest();
        _.selectOption(_.rootElement, 'c3p0');
        expect(_.rootScope.robot).toEqual([c3p0]);

        _.rootScope.robot = [r2d2];
        _.rootScope.$digest();
        expect(_.rootScope.robot).toEqual([r2d2]);
        expect(_.rootElement).toEqualSelect([['r2d2'], 'c3p0']);
      });
    });
    
    TestBed _;

    beforeEach(inject((TestBed tb) => _ = tb));

    describe('select-one', () {
      it('should compile children of a select without a ngModel, but not create a model for it',
          () {
        _.compile(
            '<select>'
              '<option selected="true">{{a}}</option>'
              '<option value="">{{b}}</option>'
              '<option>C</option>'
            '</select>');
        _.rootScope.$apply(() {
          _.rootScope['a'] = 'foo';
          _.rootScope['b'] = 'bar';
        });

        expect(_.rootElement.text).toEqual('foobarC');
      });

      it('should not interfere with selection via selected attr if ngModel directive is not present',
          () {
        _.compile(
            '<select>'
              '<option>not me</option>'
              '<option selected>me!</option>'
              '<option>nah</option>'
            '</select>');
        _.rootScope.$digest();

        expect(_.rootElement).toEqualSelect(['not me', ['me!'], 'nah']);
      });

      it('should work with repeated value options', () {
        _.compile(
            '<select ng-model="robot" probe="p">'
              '<option ng-repeat="r in robots">{{r}}</option>'
            '</select>');

        _.rootScope['robots'] = ['c3p0', 'r2d2'];
        _.rootScope['robot'] = 'r2d2';
        _.rootScope.$apply();

        var select = _.rootScope['p'].directive(InputSelectDirective);
        expect(_.rootElement).toEqualSelect(['c3p0', ['r2d2']]);

        _.rootElement.querySelectorAll('option')[0].selected = true;
        _.triggerEvent(_.rootElement, 'change');


        expect(_.rootElement).toEqualSelect([['c3p0'], 'r2d2']);
        expect(_.rootScope['robot']).toEqual('c3p0');

        _.rootScope.$apply(() {
          _.rootScope['robots'].insert(0, 'wallee');
        });
        expect(_.rootElement).toEqualSelect(['wallee', ['c3p0'], 'r2d2']);
        expect(_.rootScope['robot']).toEqual('c3p0');

        _.rootScope.$apply(() {
          _.rootScope['robots'] = ['c3p0+', 'r2d2+'];
          _.rootScope['robot'] = 'r2d2+';
        });

        expect(_.rootElement).toEqualSelect(['c3p0+', ['r2d2+']]);
        expect(_.rootScope['robot']).toEqual('r2d2+');
      });

      describe('empty option', () {
        it('should select the empty option when model is undefined', () {
          _.compile(
              '<select ng-model="robot">' +
                '<option value="">--select--</option>' +
                '<option value="x">robot x</option>' +
                '<option value="y">robot y</option>' +
              '</select>');
          _.rootScope.$digest();

          expect(_.rootElement).toEqualSelect([[''], 'x', 'y']);
        });

        it('should support defining an empty option anywhere in the option list', () {
          _.compile(
              '<select ng-model="robot">' +
                '<option value="x">robot x</option>' +
                '<option value="">--select--</option>' +
                '<option value="y">robot y</option>' +
              '</select>');
          _.rootScope.$digest();

          expect(_.rootElement).toEqualSelect(['x', [''], 'y']);
        });

        it('should set the model to empty string when empty option is selected', () {
          _.rootScope['robot'] = 'x';
          _.compile(
              '<select ng-model="robot" probe="p">' +
                '<option value="">--select--</option>' +
                '<option value="x">robot x</option>' +
                '<option value="y">robot y</option>' +
              '</select>');
          _.rootScope.$digest();

          var select = _.rootScope['p'].directive(InputSelectDirective);

          expect(_.rootElement).toEqualSelect(['', ['x'], 'y']);

          _.selectOption(_.rootElement, '--select--');

          expect(_.rootElement).toEqualSelect([[''], 'x', 'y']);
          expect(_.rootScope['robot']).toEqual(null);
        });

        describe('interactions with repeated options', () {
          it('should select empty option when model is undefined', () {
            _.rootScope['robots'] = ['c3p0', 'r2d2'];
            _.compile(
                '<select ng-model="robot">' +
                  '<option value="">--select--</option>' +
                  '<option ng-repeat="r in robots">{{r}}</option>' +
                '</select>');
            _.rootScope.$digest();
            expect(_.rootElement).toEqualSelect([[''], 'c3p0', 'r2d2']);
          });

          it('should set model to empty string when selected', () {
            _.rootScope['robots'] = ['c3p0', 'r2d2'];
            _.compile(
                '<select ng-model="robot" probe="p">' +
                  '<option value="">--select--</option>' +
                  '<option ng-repeat="r in robots">{{r}}</option>' +
                '</select>');
            _.rootScope.$digest();
            var select = _.rootScope['p'].directive(InputSelectDirective);

            _.selectOption(_.rootElement, 'c3p0');
            expect(_.rootElement).toEqualSelect(['', ['c3p0'], 'r2d2']);
            expect( _.rootScope['robot']).toEqual('c3p0');

            _.selectOption(_.rootElement, '--select--');

            expect(_.rootElement).toEqualSelect([[''], 'c3p0', 'r2d2']);
            expect( _.rootScope['robot']).toEqual(null);
          });

          it('should not break if both the select and repeater models change at once', () {
            _.compile(
                '<select ng-model="robot">' +
                  '<option value="">--select--</option>' +
                  '<option ng-repeat="r in robots">{{r}}</option>' +
                '</select>');
            _.rootScope.$apply(() {
              _.rootScope['robots'] = ['c3p0', 'r2d2'];
              _.rootScope['robot'] = 'c3p0';
            });

            expect(_.rootElement).toEqualSelect(['', ['c3p0'], 'r2d2']);

            _.rootScope.$apply(() {
              _.rootScope['robots'] = ['wallee'];
              _.rootScope['robot'] = '';
            });

            expect(_.rootElement).toEqualSelect([[''], 'wallee']);
          });
        });

        describe('unknown option', () {

          it("should insert&select temporary unknown option when no options-model match", () {
            _.compile(
                '<select ng-model="robot">' +
                  '<option>c3p0</option>' +
                  '<option>r2d2</option>' +
                '</select>');
            _.rootScope.$digest();
            expect(_.rootElement).toEqualSelect([['?'], 'c3p0', 'r2d2']);

            _.rootScope.$apply(() {
              _.rootScope['robot'] = 'r2d2';
            });
            expect(_.rootElement).toEqualSelect(['c3p0', ['r2d2']]);


            _.rootScope.$apply(() {
              _.rootScope['robot'] = "wallee";
            });
            expect(_.rootElement).toEqualSelect([['?'], 'c3p0', 'r2d2']);
          });

          it("should NOT insert temporary unknown option when model is undefined and empty " +
          "options is present", () {
            _.compile(
                '<select ng-model="robot">' +
                  '<option value="">--select--</option>' +
                  '<option>c3p0</option>' +
                  '<option>r2d2</option>' +
                '</select>');
            _.rootScope.$digest();

            expect(_.rootElement).toEqualSelect([[''], 'c3p0', 'r2d2']);
            expect(_.rootScope['robot']).toEqual(null);

            _.rootScope.$apply(() {
              _.rootScope['robot'] = 'wallee';
            });
            expect(_.rootElement).toEqualSelect([['?'], '', 'c3p0', 'r2d2']);

            _.rootScope.$apply(() {
              _.rootScope['robot'] = 'r2d2';
            });
            expect(_.rootElement).toEqualSelect(['', 'c3p0', ['r2d2']]);

            _.rootScope.$apply(() {
              _.rootScope['robot'] = null;
            });
            expect(_.rootElement).toEqualSelect([[''], 'c3p0', 'r2d2']);
          });

          it("should insert&select temporary unknown option when no options-model match, empty " +
          "option is present and model is defined", () {
            _.rootScope['robot'] = 'wallee';
            _.compile(
                '<select ng-model="robot">' +
                  '<option value="">--select--</option>' +
                  '<option>c3p0</option>' +
                  '<option>r2d2</option>' +
                '</select>');
            _.rootScope.$digest();

            expect(_.rootElement).toEqualSelect([['?'], '', 'c3p0', 'r2d2']);

            _.rootScope.$apply(() {
              _.rootScope['robot'] = 'r2d2';
            });
            expect(_.rootElement).toEqualSelect(['', 'c3p0', ['r2d2']]);
          });

          describe('interactions with repeated options', () {
            it('should work with repeated options', () {
              _.rootScope['robots'] = [];
              _.compile(
                  '<select ng-model="robot">' +
                    '<option ng-repeat="r in robots">{{r}}</option>' +
                  '</select>');
              _.rootScope.$apply(() {
                _.rootScope['robots'] = [];
              });

              expect(_.rootElement).toEqualSelect([['?']]);
              expect(_.rootScope['robot']).toEqual(null);

              _.rootScope.$apply(() {
                _.rootScope['robot'] = 'r2d2';
              });
              expect(_.rootElement).toEqualSelect([['?']]);
              expect(_.rootScope['robot']).toEqual('r2d2');

              _.rootScope.$apply(() {
                _.rootScope['robots'] = ['c3p0', 'r2d2'];
              });
              expect(_.rootElement).toEqualSelect(['c3p0', ['r2d2']]);
              expect(_.rootScope['robot']).toEqual('r2d2');
            });

            it('should work with empty option and repeated options', () {
              _.compile(
                  '<select ng-model="robot">' +
                    '<option value="">--select--</option>' +
                    '<option ng-repeat="r in robots">{{r}}</option>' +
                  '</select>');
              _.rootScope.$apply(() {
                _.rootScope['robots'] = [];
              });

              expect(_.rootElement).toEqualSelect([['']]);
              expect(_.rootScope['robot']).toEqual(null);

              _.rootScope.$apply(() {
                _.rootScope['robot'] = 'r2d2';
              });
              expect(_.rootElement).toEqualSelect([['?'], '']);
              expect(_.rootScope['robot']).toEqual('r2d2');

              _.rootScope.$apply(() {
                _.rootScope['robots'] = ['c3p0', 'r2d2'];
              });
              expect(_.rootElement).toEqualSelect(['', 'c3p0', ['r2d2']]);
              expect(_.rootScope['robot']).toEqual('r2d2');
            });

            it('should insert unknown element when repeater shrinks and selected option is ' +
            'unavailable', () {

              _.compile(
                  '<select ng-model="robot">' +
                    '<option ng-repeat="r in robots">{{r}}</option>' +
                  '</select>');
              _.rootScope.$apply(() {
                _.rootScope['robots'] = ['c3p0', 'r2d2'];
                _.rootScope['robot'] = 'r2d2';
              });
              expect(_.rootElement).toEqualSelect(['c3p0', ['r2d2']]);
              expect(_.rootScope['robot']).toEqual('r2d2');

              _.rootScope.$apply(() {
                _.rootScope['robots'].remove('r2d2');
              });
              expect(_.rootScope['robot']).toEqual('r2d2');
              expect(_.rootElement).toEqualSelect([['?'], 'c3p0']);

              _.rootScope.$apply(() {
                _.rootScope['robots'].insert(0, 'r2d2');
              });
              expect(_.rootElement).toEqualSelect([['r2d2'], 'c3p0']);
              expect(_.rootScope['robot']).toEqual('r2d2');

              _.rootScope.$apply(() {
                _.rootScope['robots'].clear();
              });

              expect(_.rootElement).toEqualSelect([['?']]);
              expect(_.rootScope['robot']).toEqual('r2d2');
            });
          });
        });
      });
    });


    describe('select from angular.js', () {
      TestBed _;
      beforeEach(inject((TestBed tb) => _ = tb));

      var scope, formElement, element;

      compile(html) {
        _.compile('<form name="form">' + html + '</form>');
        element = _.rootElement.querySelector('select');
        scope.$apply();
      }

      beforeEach(inject((Scope rootScope) {
        scope = rootScope;
        formElement = element = null;
      }));


      afterEach(() {
        scope.$destroy(); //disables unknown option work during destruction
      });


      describe('select-one', () {

        it('should compile children of a select without a ngModel, but not create a model for it',
            () {
          compile('<select>' +
                    '<option selected="true">{{a}}</option>' +
                    '<option value="">{{b}}</option>' +
                    '<option>C</option>' +
                  '</select>');
          scope.$apply(() {
            scope.a = 'foo';
            scope.b = 'bar';
          });

          expect(element.text).toEqual('foobarC');
        });


        it('should not interfere with selection via selected attr if ngModel directive is not present',
            () {
          compile('<select>' +
                    '<option>not me</option>' +
                    '<option selected>me!</option>' +
                    '<option>nah</option>' +
                  '</select>');
          expect(element).toEqualSelect(['not me', ['me!'], 'nah']);
        });


        xit('should require', () {
          compile(
            '<select name="select" ng-model="selection" required ng-change="change()">' +
              '<option value=""></option>' +
              '<option value="c">C</option>' +
            '</select>');

          scope.change = () {
            scope.log += 'change;';
          };

          scope.$apply(() {
            scope.log = '';
            scope.selection = 'c';
          });

          expect(scope.form.select.$error.required).toEqual(false);;
          expect(element).toEqualValid();
          expect(element).toEqualPristine();

          scope.$apply(() {
            scope.selection = '';
          });

          expect(scope.form.select.$error.required).toEqual(true);;
          expect(element).toEqualInvalid();
          expect(element).toEqualPristine();
          expect(scope.log).toEqual('');

          element[0].value = 'c';
          _.triggerEvent(element, 'change');
          expect(element).toEqualValid();
          expect(element).toEqualDirty();
          expect(scope.log).toEqual('change;');
        });


        xit('should not be invalid if no require', () {
          compile(
            '<select name="select" ng-model="selection">' +
              '<option value=""></option>' +
              '<option value="c">C</option>' +
            '</select>');

          expect(element).toEqualValid();
          expect(element).toEqualPristine();
        });


        describe('empty option', () {

          it('should select the empty option when model is undefined', () {
            compile('<select ng-model="robot">' +
                      '<option value="">--select--</option>' +
                      '<option value="x">robot x</option>' +
                      '<option value="y">robot y</option>' +
                    '</select>');

            expect(element).toEqualSelect([[''], 'x', 'y']);
          });


          it('should support defining an empty option anywhere in the option list', () {
            compile('<select ng-model="robot">' +
                      '<option value="x">robot x</option>' +
                      '<option value="">--select--</option>' +
                      '<option value="y">robot y</option>' +
                    '</select>');

            expect(element).toEqualSelect(['x', [''], 'y']);
          });
        });
      });


      describe('select-multiple', () {

        it('should support type="select-multiple"', () {
          compile(
            '<select ng-model="selection" multiple>' +
              '<option>A</option>' +
              '<option>B</option>' +
            '</select>');

          scope.$apply(() {
            scope.selection = ['A'];
          });

          expect(element).toEqualSelect([['A'], 'B']);

          scope.$apply(() {
            scope.selection.add('B');
          });

          expect(element).toEqualSelect([['A'], ['B']]);
        });

        it('should work with optgroups', () {
          compile('<select ng-model="selection" multiple>' +
                    '<optgroup label="group1">' +
                      '<option>A</option>' +
                      '<option>B</option>' +
                    '</optgroup>' +
                  '</select>');

          expect(element).toEqualSelect(['A', 'B']);
          expect(scope.selection).toEqual(null);

          scope.$apply(() {
            scope.selection = ['A'];
          });
          expect(element).toEqualSelect([['A'], 'B']);

          scope.$apply(() {
            scope.selection.add('B');
          });
          expect(element).toEqualSelect([['A'], ['B']]);
        });

        xit('should require', () {
          compile(
            '<select name="select"  ng-model="selection" multiple required>' +
              '<option>A</option>' +
              '<option>B</option>' +
            '</select>');

          scope.$apply(() {
            scope.selection = [];
          });

          expect(scope.form.select.$error.required).toEqual(true);;
          expect(element).toEqualInvalid();
          expect(element).toEqualPristine();

          scope.$apply(() {
            scope.selection = ['A'];
          });

          expect(element).toEqualValid();
          expect(element).toEqualPristine();

          element[0].value = 'B';
          _.triggerEvent(element, 'change');
          expect(element).toEqualValid();
          expect(element).toEqualDirty();
        });
      });


      describe('ngOptions', () {
        createSelect(attrs, [blank, unknown, ngRepeat, text, ngValue]) {
          var html = '<select';
          attrs.forEach((key, value) {
            if (value is bool) {
              if (value != null) html += ' $key';
            } else {
              html += ' $key="$value"';
            }
          });
          html += '>' +
            (blank != null ? (blank is String ? blank : '<option value="">blank</option>') : '') +
            (unknown != null ? (unknown is String ? unknown : '<option value="?">unknown</option>') : '') +
            (ngRepeat != null ? '<option ng-repeat="$ngRepeat" ng-value="$ngValue">{{$text}}</option>' : '') +
          '</select>';

          compile(html);
        }

        createSingleSelect([blank, unknown]) {
          createSelect({
            'ng-model':'selected'
          }, blank, unknown, 'value in values', 'value.name', 'value');
        }

        createMultiSelect([blank, unknown]) {
          createSelect({
            'ng-model':'selected',
            'multiple':true
          }, blank, unknown, 'value in values', 'value.name', 'value');
        }


        it('should render a list', () {
          createSingleSelect();

          scope.$apply(() {
            scope.values = [{'name': 'A'}, {'name': 'B'}, {'name': 'C'}];
            scope.selected = scope.values[0];
          });

          var options = element.querySelectorAll('option');
          expect(options.length).toEqual(3);
          expect(element).toEqualSelect([['A'], 'B', 'C']);
        });

        it('should render zero as a valid display value', () {
          createSingleSelect();

          scope.$apply(() {
            scope.values = [{'name': '0'}, {'name': '1'}, {'name': '2'}];
            scope.selected = scope.values[0];
          });

          var options = element.querySelectorAll('option');
          expect(options.length).toEqual(3);
          expect(element).toEqualSelect([['0'], '1', '2']);
        });

        it('should grow list', () {
          createSingleSelect();

          scope.$apply(() {
            scope.values = [];
          });

          expect(element.querySelectorAll('option').length).toEqual(1); // because we add special empty option
          expect(element.querySelectorAll('option')[0].text).toEqual('');
          expect(element.querySelectorAll('option')[0].value).toEqual('?');

          scope.$apply(() {
            scope.values.add({'name':'A'});
            scope.selected = scope.values[0];
          });

          expect(element.querySelectorAll('option').length).toEqual(1);
          expect(element).toEqualSelect([['A']]);

          scope.$apply(() {
            scope.values.add({'name':'B'});
          });

          expect(element.querySelectorAll('option').length).toEqual(2);
          expect(element).toEqualSelect([['A'], 'B']);
        });


        it('should shrink list', () {
          createSingleSelect();

          scope.$apply(() {
            scope.values = [{'name':'A'}, {'name':'B'}, {'name':'C'}];
            scope.selected = scope.values[0];
          });

          expect(element.querySelectorAll('option').length).toEqual(3);

          scope.$apply(() {
            scope.values.removeLast();
          });

          expect(element.querySelectorAll('option').length).toEqual(2);
          expect(element).toEqualSelect([['A'], 'B']);

          scope.$apply(() {
            scope.values.removeLast();
          });

          expect(element.querySelectorAll('option').length).toEqual(1);
          expect(element).toEqualSelect([['A']]);

          scope.$apply(() {
            scope.values.removeLast();
            scope.selected = null;
          });

          expect(element.querySelectorAll('option').length).toEqual(1); // we add back the special empty option
        });


        it('should shrink and then grow list', () {
          createSingleSelect();

          scope.$apply(() {
            scope.values = [{'name':'A'}, {'name':'B'}, {'name':'C'}];
            scope.selected = scope.values[0];
          });

          expect(element.querySelectorAll('option').length).toEqual(3);

          scope.$apply(() {
            scope.values = [{'name': '1'}, {'name': '2'}];
            scope.selected = scope.values[0];
          });

          expect(element.querySelectorAll('option').length).toEqual(2);

          scope.$apply(() {
            scope.values = [{'name': 'A'}, {'name': 'B'}, {'name': 'C'}];
            scope.selected = scope.values[0];
          });

          expect(element.querySelectorAll('option').length).toEqual(3);
        });


        it('should update list', () {
          createSingleSelect();

          scope.$apply(() {
            scope.values = [{'name': 'A'}, {'name': 'B'}, {'name': 'C'}];
            scope.selected = scope.values[0];
          });
          expect(element).toEqualSelect([['A'], 'B', 'C']);
          scope.$apply(() {
            scope.values = [{'name': 'B'}, {'name': 'C'}, {'name': 'D'}];
            scope.selected = scope.values[0];
          });

          var options = element.querySelectorAll('option');
          expect(options.length).toEqual(3);
          expect(element).toEqualSelect([['B'], 'C', 'D']);
        });


        it('should preserve existing options', () {
          createSingleSelect(true);

          scope.$apply(() {
            scope.values = [];
          });

          expect(element.querySelectorAll('option').length).toEqual(1);

          scope.$apply(() {
            scope.values = [{'name': 'A'}];
            scope.selected = scope.values[0];
          });

          expect(element.querySelectorAll('option').length).toEqual(2);
          expect(element.querySelectorAll('option')[0].text).toEqual('blank');
          expect(element.querySelectorAll('option')[1].text).toEqual('A');

          scope.$apply(() {
            scope.values = [];
            scope.selected = null;
          });

          expect(element.querySelectorAll('option').length).toEqual(1);
          expect(element.querySelectorAll('option')[0].text).toEqual('blank');
        });

        describe('binding', () {

          it('should bind to scope value', () {
            createSingleSelect();

            scope.$apply(() {
              scope.values = [{'name': 'A'}, {'name': 'B'}];
              scope.selected = scope.values[0];
            });

            expect(element).toEqualSelect([['A'], 'B']);

            scope.$apply(() {
              scope.selected = scope.values[1];
            });

            expect(element).toEqualSelect(['A', ['B']]);
          });


          // TODO(misko): re-enable once we support group by
          xit('should bind to scope value and group', () {
            createSelect({
              'ng-model': 'selected',
              'ng-options': 'item.name group by item.group for item in values'
            });

            scope.$apply(() {
              scope.values = [{'name': 'A'},
                              {'name': 'B', group: 'first'},
                              {'name': 'C', group: 'second'},
                              {'name': 'D', group: 'first'},
                              {'name': 'E', group: 'second'}];
              scope.selected = scope.values[3];
            });

            expect(element).toEqualSelect(['A', 'B', ['D'], 'C', 'E']);

            var first = element.querySelectorAll('optgroup')[0];
            var b = first.querySelectorAll('option')[0];
            var d = first.querySelectorAll('option')[1];
            expect(first.attr('label')).toEqual('first');
            expect(b.text).toEqual('B');
            expect(d.text).toEqual('D');

            var second = element.querySelectorAll('optgroup')[1];
            var c = second.querySelectorAll('option')[0];
            var e = second.querySelectorAll('option')[1];
            expect(second.attr('label')).toEqual('second');
            expect(c.text).toEqual('C');
            expect(e.text).toEqual('E');

            scope.$apply(() {
              scope.selected = scope.values[0];
            });

            expect(element.value).toEqual('0');
          });


          it('should bind to scope value through experession', () {
            createSelect({'ng-model': 'selected'}, null, null, 'item in values', 'item.name', 'item.id');

            scope.$apply(() {
              scope.values = [{'id': 10, 'name': 'A'}, {'id': 20, 'name': 'B'}];
              scope.selected = scope.values[0]['id'];
            });

            expect(element).toEqualSelect([['A'], 'B']);

            scope.$apply(() {
              scope.selected = scope.values[1]['id'];
            });

            expect(element).toEqualSelect(['A', ['B']]);
          });


          it('should insert a blank option if bound to null', () {
            createSingleSelect();

            scope.$apply(() {
              scope.values = [{'name': 'A'}];
              scope.selected = null;
            });

            expect(element.querySelectorAll('option').length).toEqual(2);
            expect(element).toEqualSelect([['?'], 'A']);
            expect(element.querySelectorAll('option')[0].value).toEqual('?');

            scope.$apply(() {
              scope.selected = scope.values[0];
            });

            expect(element).toEqualSelect([['A']]);
            expect(element.querySelectorAll('option').length).toEqual(1);
          });


          it('should reuse blank option if bound to null', () {
            createSingleSelect(true);

            scope.$apply(() {
              scope.values = [{'name': 'A'}];
              scope.selected = null;
            });

            expect(element.querySelectorAll('option').length).toEqual(2);
            expect(element.value).toEqual('');
            expect(element.querySelectorAll('option')[0].value).toEqual('');

            scope.$apply(() {
              scope.selected = scope.values[0];
            });

            expect(element).toEqualSelect(['', ['A']]);
            expect(element.querySelectorAll('option').length).toEqual(2);
          });


          it('should insert a unknown option if bound to something not in the list', () {
            createSingleSelect();

            scope.$apply(() {
              scope.values = [{'name': 'A'}];
              scope.selected = {};
            });

            expect(element.querySelectorAll('option').length).toEqual(2);
            expect(element.value).toEqual('?');
            expect(element.querySelectorAll('option')[0].value).toEqual('?');

            scope.$apply(() {
              scope.selected = scope.values[0];
            });

            expect(element).toEqualSelect([['A']]);
            expect(element.querySelectorAll('option').length).toEqual(1);
          });


          it('should select correct input if previously selected option was "?"', () {
            createSingleSelect();

            scope.$apply(() {
              scope.values = [{'name': 'A'}, {'name': 'B'}];
              scope.selected = {};
            });

            expect(element.querySelectorAll('option').length).toEqual(3);
            expect(element.value).toEqual('?');
            expect(element.querySelectorAll('option')[0].value).toEqual('?');

            _.selectOption(element, 'A');
            expect(scope.selected).toBe(scope.values[0]);
            expect(element.querySelectorAll('option')[0].selected).toEqual(true);
            expect(element.querySelectorAll('option')[0].selected).toEqual(true);;
            expect(element.querySelectorAll('option').length).toEqual(2);
          });
        });


        describe('blank option', () {

          it('should be compiled as template, be watched and updated', () {
            var option;
            createSingleSelect('<option value="">blank is {{blankVal}}</option>');

            scope.$apply(() {
              scope.blankVal = 'so blank';
              scope.values = [{'name': 'A'}];
            });

            // check blank option is first and is compiled
            expect(element.querySelectorAll('option').length).toEqual(2);
            option = element.querySelectorAll('option')[0];
            expect(option.value).toEqual('');
            expect(option.text).toEqual('blank is so blank');

            scope.$apply(() {
              scope.blankVal = 'not so blank';
            });

            // check blank option is first and is compiled
            expect(element.querySelectorAll('option').length).toEqual(2);
            option = element.querySelectorAll('option')[0];
            expect(option.value).toEqual('');
            expect(option.text).toEqual('blank is not so blank');
          });


          it('should support binding via ngBindTemplate directive', () {
            var option;
            createSingleSelect('<option value="" ng-bind="\'blank is \' + blankVal"></option>');

            scope.$apply(() {
              scope.blankVal = 'so blank';
              scope.values = [{'name': 'A'}];
            });

            // check blank option is first and is compiled
            expect(element.querySelectorAll('option').length).toEqual(2);
            option = element.querySelectorAll('option')[0];
            expect(option.value).toEqual('');
            expect(option.text).toEqual('blank is so blank');
          });


          it('should support biding via ngBind attribute', () {
            var option;
            createSingleSelect('<option value="" ng-bind="blankVal"></option>');

            scope.$apply(() {
              scope.blankVal = 'is blank';
              scope.values = [{'name': 'A'}];
            });

            // check blank option is first and is compiled
            expect(element.querySelectorAll('option').length).toEqual(2);
            option = element.querySelectorAll('option')[0];
            expect(option.value).toEqual('');
            expect(option.text).toEqual('is blank');
          });


          it('should be rendered with the attributes preserved', () {
            var option;
            createSingleSelect('<option value="" class="coyote" id="road-runner" ' +
              'custom-attr="custom-attr">{{blankVal}}</option>');

            scope.$apply(() {
              scope.blankVal = 'is blank';
            });

            // check blank option is first and is compiled
            option = element.querySelectorAll('option')[0];
            expect(option.classes.contains('coyote')).toEqual(true);;
            expect(option.attributes['id']).toEqual('road-runner');
            expect(option.attributes['custom-attr']).toEqual('custom-attr');
          });

          it('should be selected, if it is available and no other option is selected', () {
            // selectedIndex is used here because $ incorrectly reports element.value
            scope.$apply(() {
              scope.values = [{'name': 'A'}];
            });
            createSingleSelect(true);
            // ensure the first option (the blank option) is selected
            expect(element.selectedIndex).toEqual(0);
            scope.$digest();
            // ensure the option has not changed following the digest
            expect(element.selectedIndex).toEqual(0);
          });
        });


        describe('on change', () {

          it('should update model on change', () {
            createSingleSelect();

            scope.$apply(() {
              scope.values = [{'name': 'A'}, {'name': 'B'}];
              scope.selected = scope.values[0];
            });

            expect(element.querySelectorAll('option')[0].selected).toEqual(true);

            element.querySelectorAll('option')[1].selected = true;
            _.triggerEvent(element, 'change');
            expect(scope.selected).toEqual(scope.values[1]);
          });


          it('should update model on change through expression', () {
            createSelect({'ng-model': 'selected'}, null, null,
                'item in values', 'item.name', 'item.id');

            scope.$apply(() {
              scope.values = [{'id': 10, 'name': 'A'}, {'id': 20, 'name': 'B'}];
              scope.selected = scope.values[0]['id'];
            });

            expect(element).toEqualSelect([['A'], 'B']);

            element.querySelectorAll('option')[1].selected = true;
            _.triggerEvent(element, 'change');
            expect(scope.selected).toEqual(scope.values[1]['id']);
          });


          it('should update model to null on change', () {
            createSingleSelect(true);

            scope.$apply(() {
              scope.values = [{'name': 'A'}, {'name': 'B'}];
              scope.selected = scope.values[0];
              element.value = '0';
            });

            _.selectOption(element, 'blank');
            expect(element).toEqualSelect([[''], 'A', 'B']);

            expect(scope.selected).toEqual(null);
          });
        });


        describe('select-many', () {

          it('should read multiple selection', () {
            createMultiSelect();

            scope.$apply(() {
              scope.values = [{'name': 'A'}, {'name': 'B'}];
              scope.selected = [];
            });

            expect(element.querySelectorAll('option').length).toEqual(2);
            expect(element.querySelectorAll('option')[0].selected).toEqual(false);;
            expect(element.querySelectorAll('option')[1].selected).toEqual(false);;

            scope.$apply(() {
              scope.selected.add(scope.values[1]);
            });

            expect(element.querySelectorAll('option').length).toEqual(2);
            expect(element.querySelectorAll('option')[0].selected).toEqual(false);;
            expect(element.querySelectorAll('option')[1].selected).toEqual(true);;

            scope.$apply(() {
              scope.selected.add(scope.values[0]);
            });

            expect(element.querySelectorAll('option').length).toEqual(2);
            expect(element.querySelectorAll('option')[0].selected).toEqual(true);;
            expect(element.querySelectorAll('option')[1].selected).toEqual(true);;
          });


          it('should update model on change', () {
            createMultiSelect();

            scope.$apply(() {
              scope.values = [{'name': 'A'}, {'name': 'B'}];
              scope.selected = [];
            });

            element.querySelectorAll('option')[0].selected = true;

            _.triggerEvent(element, 'change');
            expect(scope.selected).toEqual([scope.values[0]]);
          });


          it('should deselect all options when model is emptied', () {
            createMultiSelect();
            scope.$apply(() {
              scope.values = [{'name': 'A'}, {'name': 'B'}];
              scope.selected = [scope.values[0]];
            });
            expect(element.querySelectorAll('option')[0].selected).toEqual(true);

            scope.$apply(() {
              scope.selected.removeLast();
            });

            expect(element.querySelectorAll('option')[0].selected).toEqual(false);
          });
        });


        xdescribe('ngRequired', () {

          it('should allow bindings on ngRequired', () {
            createSelect({
              'ng-model': 'value',
              'ng-options': 'item.name for item in values',
              'ng-required': 'required'
            }, true);


            scope.$apply(() {
              scope.values = [{'name': 'A', 'id': 1}, {'name': 'B', 'id': 2}];
              scope.required = false;
            });

            element.value = '';
            _.triggerEvent(element, 'change');
            expect(element).toEqualValid();

            scope.$apply(() {
              scope.required = true;
            });
            expect(element).toEqualInvalid();

            scope.$apply(() {
              scope.value = scope.values[0];
            });
            expect(element).toEqualValid();

            element.value = '';
            _.triggerEvent(element, 'change');
            expect(element).toEqualInvalid();

            scope.$apply(() {
              scope.required = false;
            });
            expect(element).toEqualValid();
          });
        });
      });


      describe('option', () {

        it('should populate value attribute on OPTION', () {
          compile('<select ng-model="x"><option selected>abc</option></select>');
          expect(element).toEqualSelect([['?'], 'abc']);
        });

        it('should ignore value if already exists', () {
          compile('<select ng-model="x"><option value="abc">xyz</option></select>');
          expect(element).toEqualSelect([['?'], 'abc']);
        });

        it('should set value even if self closing HTML', () {
          scope.x = 'hello';
          compile('<select ng-model="x"><option>hello</select>');
          expect(element).toEqualSelect([['hello']]);
        });

        it('should not blow up when option directive is found inside of a datalist',
            () {
          _.compile('<div>' +
                      '<datalist><option>some val</option></datalist>' +
                      '<span>{{foo}}</span>' +
                    '</div>');

          _.rootScope.foo = 'success';
          _.rootScope.$digest();
          expect(_.rootElement.querySelector('span').text).toEqual('success');
        });
      });
    });
  });
}
