'use strict';var _react=require('react');var _react2=_interopRequireDefault(_react);var _reactDom=require('react-dom');var _reactDom2=_interopRequireDefault(_reactDom);var _routes=require('./routes');var _routes2=_interopRequireDefault(_routes);var _reduxRouter=require('./node/redux-router');var _reduxRouter2=_interopRequireDefault(_reduxRouter);var _reducers=require('./redux/reducers');var _reducers2=_interopRequireDefault(_reducers);function _interopRequireDefault(obj){return obj&&obj.__esModule?obj:{default:obj};}require('es6-promise').polyfill();(0,_reduxRouter.setupReducers)(_reducers2.default);(0,_reduxRouter2.default)(_routes2.default);if(module.hot){module.hot.accept('./routes',function(){// reload routes again
require('./routes').default;(0,_reduxRouter2.default)(_routes2.default);});module.hot.accept('./redux/reducers',function(){// reload reducers again
var newReducers=require('./redux/reducers');(0,_reduxRouter.replaceReducers)(newReducers);});};var _temp=function(){if(typeof __REACT_HOT_LOADER__==='undefined'){return;}}();;