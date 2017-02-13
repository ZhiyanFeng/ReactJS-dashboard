import React from 'react';

import {
  Row,
  Tab,
  Col,
  Nav,
  Icon,
  Grid,
  Form,
  Table,
  Label,
  Panel,
  Button,
  NavItem,
  Checkbox,
  Progress,
  PanelBody,
  FormGroup,
  PanelLeft,
  isBrowser,
  InputGroup,
  LoremIpsum,
  PanelRight,
  PanelHeader,
  FormControl,
  PanelContainer,
  PanelTabContainer,
} from '@sketchpixy/rubix';

export default class RevenuePanel extends React.Component {

    constructor(props){
        super(props);
    }

    render() {
        return (
            <Grid>
                <Row>
                    <Col xs={12} className='text-center'>
                        <br/>
                        <div>
                            <h4>Today</h4>
                            <h2 className='fg-green visible-xs visible-md visible-lg'>{this.props.count}</h2>
                            <h4 className='fg-green visible-sm'>{this.props.count}</h4>
                        </div>
                        <hr className='border-green'/>
                        <div>
                            <h4>Two weeks</h4>
                            <h2 className='fg-green visible-xs visible-md visible-lg'>{this.props.twoWeekCount}</h2>
                            <h4 className='fg-green visible-sm'>{this.props.twoWeekCount}</h4>
                        </div>
                    </Col>
                </Row>
            </Grid>
        );
    }
}

