// Detalhamento de uma pesquisa

import React, { useState, useEffect } from 'react';
import { useHistory, useLocation } from "react-router-dom";
import { Scrollchor } from 'react-scrollchor';
import api from '../../services/api';
import { Button, TextField, CircularProgress } from '@material-ui/core';
import { Add, Edit } from '@material-ui/icons';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpwardRounded';
import './styles.css';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogContentText from '@mui/material/DialogContentText';
import DialogTitle from '@mui/material/DialogTitle';

import { connect } from 'react-redux';

function ShowSurvey({user}) {

	const location = useLocation();
  console.log("LOCATION", location);
	const history = useHistory();
  const [description, setDescription] = useState('');
	
  const [survey, setSurvey] = useState([]);
	const [modules, setModules] = useState([]);
  const [moduleID, setModuleID] = useState(''); // ID do módulo clicado
  const [moduleStatus, setModuleStatus] = useState('');
  const [motherID, setMotherID] = useState(''); // ID do mãe, se houver 
  const [motherModules, setMotherModules] = useState([]); // Módulos das mãe, se houver
  const [search, setSearch] = useState('');
  const [error, setError] = useState('');
  const [modulesLoaded, setModulesLoaded] = useState(false);
  const [loadingSearch, setLoadingSearch] = useState(false);
  const [popupTitle, setPopupTitle] = useState('');
  const [popupBodyText, setPopupBodyText] = useState('');
  const [canShowPublishButton, setCanShowPublishButton] = useState(false);
  const [canBePublished, setCanBePublished] = useState(false);
  const [popupAction, setPopupAction] = useState('');

	useEffect(() => {

      async function loadModules() {
          setModulesLoaded(false);
          const response = await api.get('/modules/'+location.state.questionnaireID);
          if(response.data) {
            setModules(response.data);
            setModulesLoaded(true);
          }  
			    console.log("Modules", modules.length);
      }                                                                                                                                                                                                       
      loadModules();
      // obtem informações da pesquisa
      async function loadSurveyInfo() {
        const response = await api.get('/survey/'+location.state.questionnaireID);
        if(response.data){
          setSurvey(response.data);
        }
      }                                                                                                                                                                                                       
      loadSurveyInfo();
      // módulos da mãe da pesquisa
      async function loadMotherModules() {
        const response = await api.get('/mothermodules/'+location.state.questionnaireID);
        if(response.data){
          setMotherModules(response.data);
        }
      }                                                                                                                                                                                                       
      loadMotherModules();
  }, [])

	function getPtBrDate(somedate) {
      //var today = new Date();
      var dd = String(somedate.getDate()).padStart(2, '0');
      var mm = String(somedate.getMonth() + 1).padStart(2, '0');
      var yyyy = somedate.getFullYear();
      return dd + '/' + mm + '/' + yyyy;
  }

  // popup  
	const [open, setOpen] = React.useState(false);
  const handleClickOpen = (q) => {

        setOpen(false);
        setModuleID(q.crfFormsID);
        setModuleStatus(q.crfFormsStatus);
        setMotherID(q.questionnaireID);
        setPopupBodyText("");
        const moduleID = q.crfFormsID
        const motherID = q.questionnaireID
        const moduleStatus = q.crfFormsStatus
        {location.state.questionnaireStatus === "Publicado" &&
            setPopupTitle("Este questionário está em uso.");
            setPopupBodyText("Tem certeza de que deseja alterar um formulário deprecado?");
            setPopupAction("edition");
            setOpen(true);
        }
        { location.state.questionnaireStatus === "Deprecado" &&  
            setPopupTitle("Este questionário foi deprecado.");
            setPopupBodyText("Apenas edições básicas são permitidas em módulos de pesquisas publicadas.");
            setPopupAction("edition");
            setOpen(true);
        }
        {location.state.questionnaireStatus === "Novo" &&    history.push('/edit-unpublished-form', {
          modulo: moduleID,
          moduleStatus: moduleStatus,
          motherID: motherID,
          hospitalIndex: user[0].hospitalunitid,
          questionnaireID: location.state.questionnaireID,
          questionnaireStatus: location.state.questionnaireStatus,
          questionnaireDesc: location.state.description,
          questionnaireVers: location.state.version
        });}

  };
  const handleClose = () => {
    setOpen(false);
  };

  async function handlePublishing(e){

    setPopupAction("publication");
    setPopupTitle("Publicação de "+location.state.description);
    const response = await api.get('/checkpublication/'+location.state.questionnaireID);

    if(response.data) {
      setPopupBodyText(response.data[0].msgRetorno);

      if (response.data[0].msgRetorno == "OK") {
        setCanShowPublishButton(true)
        setPopupBodyText("Atenção. Este questionário e todos os seus formulários de módulos serão publicados. Tem certeza?");
        setCanBePublished(true);
    
      }else{
        setCanShowPublishButton(false)

      }
    }  
    
    setOpen(true);
    
  }

  async function publish(e){
    const response = await api.post('/publication/'+location.state.questionnaireID);

    if(response){
      setPopupBodyText("Questionário publicado com sucesso");
      setCanShowPublishButton(false);
      setCanBePublished(false);
      const response = await api.get('/modules/'+location.state.questionnaireID);
      if(response.data) {
        setModules(response.data);
        setModulesLoaded(true);
      }  
      location.state.questionnaireStatus = "Publicado";
    }
  }

  const handleOpenEditPublishedForm = () => {
       //console.log(moduleID);
       history.push('/edit-published-form', {
            modulo: moduleID,
            moduleStatus: moduleStatus,
            motherID: motherID,
            hospitalIndex: user[0].hospitalunitid,
            questionnaireID: location.state.questionnaireID,
            questionnaireStatus: location.state.questionnaireStatus,
            questionnaireDesc: location.state.description,
            questionnaireVers: location.state.version
        });
  };

  function handleBackButton(){
      history.goBack();
  }

  async function handleSearch(e) {
      e.preventDefault();
      setError('');
      setLoadingSearch(true);
      setModulesLoaded(false);
      const response = await api.post('/searchModules', {
          descricao: search,
          questionnaireID: location.state.questionnaireID,
      }).catch( function (error) {
          setLoadingSearch(false);
          console.log(error)
          console.log(error.response.data)
      });
     
      if(response.data) {
          setLoadingSearch(false);
          setModulesLoaded(true);
          if(response.data.length > 0) {
              if(response.data[0].msgRetorno) {
                  setError(response.data[0].msgRetorno)
              } else {
                  setError('')
              }
          }
      }

      setModules(response.data)
      //console.log("modules", modules);
  }

  function handleChange(e) {
      const target = e.target;
      const value = target.value;
      //console.log(value);
      setSearch(value);
  }

	return (

	  <main className="container containerWider">
	    <div className="module">
        <div className="mainNav">
          <span className="descDesc">Pesquisa:</span><h2>{location.state.description}</h2>
          <ArrowBackIcon className="ArrowBack" onClick={handleBackButton}/>
          <Scrollchor to="#vodan_br"><ArrowUpwardIcon className="ArrowUp" /></Scrollchor>
        </div>
        <div className="survey-details">
          <p>Versão: <span className="detail">{location.state.version}</span></p><br/>
          <p className="padding-10">Status: {location.state.questionnaireStatus}</p><br/>
          <p>Data de criação: {location.state.creationDate}</p><br/>
          <p className="padding-10">Última modificação: {location.state.lastModification}</p><br/>
        </div>
        <div className="mother-details">
          {  !(modules.length > 0 && modulesLoaded) &&
              survey.map(q =>(
               <p>Esta pesquisa é {q.motherRelationship} de {q.motherDescription}.</p>
              ))   
          } 
        </div>
        <div className="search-options">
          <form noValidate autoComplete="off" onSubmit={handleSearch}>
            <TextField className="inputDescription" id="standard-basic" label="Descrição do módulo" onChange={handleChange}/>
            <Button variant="contained" color="primary" type="submit">
              { !loadingSearch &&
                'Buscar'
              }
              { loadingSearch &&
                <CircularProgress color="white"/>
              }
            </Button>
          </form>
        </div>
        <Button variant="outlined" color="primary" className="add-module" onClick={ () => {
          history.push('/add-module',  
          {questionnaireID: location.state.questionnaireID, 
                    description : location.state.description,
                                    version : location.state.version,
                                    questionnaireStatus : location.state.questionnaireStatus,
                                    lastModification: location.state.lastModification,
                                    creationDate: location.state.creationDate
                  })
        }}>
        <Add color="primary" />
          Adicionar novo formulário de módulo +
        </Button><br/>
        <Button variant="contained" color="primary" className="add-module publish" onClick={handlePublishing}>
          <Add color="primary" />
          Publicar pesquisa
        </Button><br/>
        <Button variant="outlined" color="primary" className="add-survey add-based " onClick={ () => {
          history.push('/add-based-survey')
        }}>
          <Add color="primary" />
          Adicionar pesquisa derivada
        </Button>
        { (error) &&
          <span className="error">{ error }</span>
        }
        { !error && 
        <div className="modules-list">
          <table>
            <thead>
              <tr>
                <th>MÓDULO</th>
                <th>STATUS</th>
                <th>CRIADO EM</th> 
                <th>MODIFICADO EM</th> 
                <th>EDITAR</th> 
              </tr>
            </thead>
            <tbody>
            {  modules.length > 0 &&
                                modules.map(q => ( 
                                      <tr value={q.description} key={q.crfFormsID} data-key={q.description} onClick={() => handleClickOpen(q)}>
                                          <td>{q.description}</td>
                                          <td>{q.crfFormsStatus}</td>
                                          <td>{getPtBrDate(new Date(q.creationDate))}</td> 
                                          <td>{getPtBrDate(new Date(q.lastModification))}</td> 
                                          <td><Edit /></td>
                                      </tr>
                                ))
            }
            { !(modules.length > 0) &&
                   motherModules.map(q => ( 
                      <tr value={q.description} key={q.crfFormsID} data-key={q.description} onClick={() => handleClickOpen(q)}>
                          <td>{q.description}</td>
                          <td>{q.crfFormsStatus}</td>
                          <td>{getPtBrDate(new Date(q.creationDate))}</td> 
                          <td>{getPtBrDate(new Date(q.lastModification))}</td> 
                          <td><Edit /></td>
                      </tr>
                    ))
            }
            </tbody>
                    <Dialog key={location.state.questionnaireStatus}
                      open={open}
                      onClose={handleClose}
                      aria-labelledby="alert-dialog-title"
                      aria-describedby="alert-dialog-description"
                    >
                      <DialogTitle id="alert-dialog-title">
                        {popupTitle}
                      </DialogTitle>
                      <DialogContent>
                        <DialogContentText id="alert-dialog-description">
                        { location.state.questionnaireStatus === "Publicado" && popupAction == "edition" &&
                        "Apenas edições básicas são permitidas em formulários de pesquisas publicadas."}
                        { location.state.questionnaireStatus === "Deprecado" && popupAction == "edition" &&
                        "Tem certeza de que deseja alterar um formulário deprecado?"}
                        {popupBodyText}
                        </DialogContentText>
                      </DialogContent>  
                      <DialogActions>
                        <Button onClick={handleClose}>Fechar [x]</Button>
                        {
                          popupAction == "edition" && <Button onClick={handleOpenEditPublishedForm} autoFocus>Prosseguir</Button> 
                        }
                        {
                          popupAction == "publication" && canShowPublishButton && <Button onClick={!canBePublished ? handlePublishing : publish} autoFocus>Publicar</Button>
                        }
                      </DialogActions>
                    </Dialog>
          </table>
        </div>
        }
		 </div>
    </main>

	);

}

export default connect(state => ({ user: state.user }))(ShowSurvey);