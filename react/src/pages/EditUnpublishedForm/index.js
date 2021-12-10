import React, { useState, useEffect } from 'react';
import { useHistory, useLocation } from "react-router-dom";
import api from '../../services/api';
import { Button, TextField, CircularProgress, Select } from '@material-ui/core';
import { Add, Edit } from '@material-ui/icons';
import './styles.css';

import { connect } from 'react-redux';

function EditUnpublishedForm({user}) {

	return (
		<main className="container unpublished">
			<div className="col-left">

			</div>
			<div className="col-right">
				
			</div>
		</main>
	);






}

export default connect(state => ({ user: state.user }))(EditUnpublishedForm);
