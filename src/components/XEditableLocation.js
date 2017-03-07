import React from 'react';
import axios from 'axios';

import {
  Row,
  Col,
  Nav,
  Grid,
  Form,
  Panel,
  Radio,
  Table,
  Button,
  Checkbox,
  PanelBody,
  FormGroup,
  InputGroup,
  PanelHeader,
  ButtonGroup,
  FormControl,
  PanelFooter,
  ControlLabel,
  PanelContainer,
} from '@sketchpixy/rubix';

export default class XEditableLocation extends React.Component {
    constructor(props){
        super(props);
        this.state ={
            mode: 'popup',
        };
        this.updatelocation = this.updatelocation.bind(this);
        this.updatelocationApiCall = this.updatelocationApiCall.bind(this);
    }

    updatelocation(value){
        this.editPhoneApiCall(this.props.operation, this.props.location_id, value, localStorage.getItem('key'));
    }

    updatelocationApiCall(id, query, key){
        const config = {
            headers: {
                'X-Method': 'pass_verification',
                'Session-Token': '1333',
                'Accept': 'application/vnd.Expresso.v1',
                'Authorization': `Token token=${key}, nonce="def"`,
                'Content-Type': 'application/json'
            }
        }
        if(opration === 'location_name'){
            return axios.post(`http://internal.coffeemobile.com/api/locations/${id}/update_location`, {'location_name': query}, config).then(res => {
                //dispatch(setSearchlocations(res.data.eXpresso));
            });
        }
    }



    renderEditable() {
        // $('.xeditable').editable({
        // $(mode: this.state.mode
        //})// $(;
        var temp = this;
        $('#name').editable({
            validate: function(value) {
                if($.trim(value) == ''){ 
                    return 'This field is required';
                }else{
                    temp.updatelocation(value);
                };
            }
        });
    }

    componentDidMount() {
        this.renderEditable();
    }

    render() {
        var name = this.props.name !=null ? this.props.name : 'Location name';
        if(this.props.operation === 'location_name'){
            return(
                <h4 id='name' className='fg-white text-center'>
                    <a href='#' ref='name' className='xeditable' data-type='text' data-title='Enter location name'>{name}</a>
                </h4>
            );
        }
    }
}
