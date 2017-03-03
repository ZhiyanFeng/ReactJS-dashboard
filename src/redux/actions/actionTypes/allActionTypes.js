import apiUserActionType from './apiUserActionType';
import apiDataActionType from './apiDataActionType';
import apiLocationActionType from './apiLocationActionType';
import apiGoogleActionType from './apiGoogleActionType';
import apiChannelActionType from './apiChannelActionType';

module.exports = {
    ...apiUserActionType,
    ...apiDataActionType,
    ...apiLocationActionType,
    ...apiGoogleActionType,
    ...apiChannelActionType
};
