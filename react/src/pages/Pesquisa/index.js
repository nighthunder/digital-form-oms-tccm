import React, { useState } from 'react';
import { useHistory, useLocation } from "react-router-dom";
import { Button, TextField, CircularProgress } from '@material-ui/core';
import { Add, Edit } from '@material-ui/icons';
import './styles.css';

import { connect } from 'react-redux';

function Pesquisa({user}) {

    const location = useLocation();

    const history = useHistory();

	return (
            <div className="pesquisa">
				<h2>Criação de pesquisas</h2>
				<Button variant="outlined" color="primary" className="add-prontuario add-pesquisa" onClick={ () => {
                    history.push('/add-prontuario', { hospitalIndex: location.state.hospitalIndex })
                }}>
                    <Add color="primary" />
                    Adicionar nova Pesquisa
                </Button>
                <div className="pesquisas-list">
                    
                </div>
			</div>
     );

}

export default Pesquisa;