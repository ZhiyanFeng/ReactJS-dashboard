'use strict';exports.__esModule=true;exports.default=validateInput;var _validator=require('validator');var _validator2=_interopRequireDefault(_validator);var _isEmpty=require('lodash/isEmpty');var _isEmpty2=_interopRequireDefault(_isEmpty);function _interopRequireDefault(obj){return obj&&obj.__esModule?obj:{default:obj};}function validateInput(data){var errors={};if(!_validator2.default.isEmail(data.email)){errors.email='Email is invalid';}if(_validator2.default.isEmpty(data.password)){errors.password='This field is required';}//if (Validator.isNull(data.passwordConfirmation)) {
//iferrors.passwordConfirmation = 'This field is required';
//}
//if (!Validator.equals(data.password, data.passwordConfirmation)) {
//iferrors.passwordConfirmation = 'Passwords must match';
//}
return{errors:errors,isValid:(0,_isEmpty2.default)(errors)};};var _temp=function(){if(typeof __REACT_HOT_LOADER__==='undefined'){return;}__REACT_HOT_LOADER__.register(validateInput,'validateInput','src/components/login/loginValidation.js');}();;