String loginMobileOem = '''
              mutation loginMobileOem (\$input: userCredentials) {
                  loginMobileOem (input: \$input)
              },
          ''';

const String currentUser = r'''
    query currentUser {
      currentUser() {
        _id
        name
        username
        role
        foldersAccessToken
        email
        info
        facility {
            _id
            name
            oem {
                _id
                name
                logo
                thumbnail
                backgroundColor
                textColor
                urlOem
                slug
                urlOemFacility
            }
            machines {
                _id
                name
                serialNumber
                description
                documentationFiles
                issues
                documents {
                    _id
                    label
                    href
                    visibleForFacility
                }
                documentTree {
                    _id
                    dataTree {
                        _id
                        rootId
                        items
                    }
                    machine {
                        _id
                        name
                        serialNumber
                        description
                        documentationFiles
                        issues
                        image
                        thumbnail
                        totalOpenTickets
                        slug
                    }
                }
                customers {
                    _id
                    name
                    oem {
                        _id
                        name
                        logo
                        thumbnail
                        backgroundColor
                        textColor
                        urlOem
                        slug
                        urlOemFacility
                    }
                    machines {
                        _id
                        name
                        serialNumber
                        description
                        documentationFiles
                        issues
                        image
                        thumbnail
                        totalOpenTickets
                        slug
                    }
                    urlOemFacility
                    totalMachines
                    totalOpenTickets
                    isQRCodeEnabled
                    generalAccessUrl
                }
                oem {
                    _id
                    name
                    logo
                    thumbnail
                    backgroundColor
                    textColor
                    urlOem
                    slug
                    urlOemFacility
                }
                image
                thumbnail
                totalOpenTickets
                slug
            }
            urlOemFacility
            totalMachines
            totalOpenTickets
            isQRCodeEnabled
            generalAccessUrl
        }
        oem {
            _id
            name
            logo
            thumbnail
            backgroundColor
            textColor
            urlOem
            slug
            urlOemFacility
        }
        access
        userType
        phone
        about
        userCredentialsSent
        isOem
        emailNotification
        totalActiveTickets
        organizationName
        organizationType
        chatToken
        chatUUIDMetadata
        chatKeys
        chatUUID
      }
    }
  ''';

const String newChatToken = '''
    query getNewChatToken {
      getNewChatToken
    }
  ''';

String listOwnOemOpenTickets = r"""
          query listOwnOemOpenTickets {
            listOwnOemOpenTickets() {
                _id
                title
                ticketId
                ticketType
                description 
                status 
                unread
                isMyTicket
                ticketChatChannels
                createdAt
                ticketInternalNotesChatChannels
                facility {
                  _id
                  name 
                
                }
                machine {
                    _id
                    name
                    serialNumber  
                }
                assignee {
                  _id
                  name
                }
            }    
          }
   """;

String listOwnOemClosedTickets = r"""
          query listOwnOemClosedTickets {
            listOwnOemClosedTickets() {
                _id
                title
                ticketId
                ticketType
                description 
                status
                createdAt
                unread
                isMyTicket
                ticketChatChannels
                ticketInternalNotesChatChannels
                facility {
                  _id
                  name  
                }
                machine {
                    _id
                    name
                    serialNumber 
                }
                assignee {
                  _id
                  name
                }
            }    
          }
   """;

String listOwnOemUserOpenTickets = r"""
          query listOwnOemUserOpenTickets {
            listOwnOemUserOpenTickets() {
                _id
                title
                ticketId
                ticketType
                description 
                status 
                unread
                isMyTicket
                ticketChatChannels
                createdAt
                ticketInternalNotesChatChannels
                facility {
                  _id
                  name 
                
                }
                machine {
                    _id
                    name
                    serialNumber  
                }
                assignee {
                  _id
                  name
                }
            }    
          }
   """;

String listOwnOemUserClosedTickets = r"""
          query listOwnOemUserClosedTickets {
            listOwnOemUserClosedTickets() {
                _id
                title
                ticketId
                ticketType
                description 
                status 
                unread
                isMyTicket
                ticketChatChannels
                createdAt
                ticketInternalNotesChatChannels
                facility {
                  _id
                  name 
                
                }
                machine {
                    _id
                    name
                    serialNumber  
                }
                assignee {
                  _id
                  name
                }
            }    
          }
   """;

String listOwnCustomerMachines = r"""
          query listOwnCustomerMachines {
            listOwnCustomerMachines() {
                _id
                name
                serialNumber
                description
                documentationFiles
                issues
                image
                thumbnail
                totalOpenTickets
                slug
                customers {
                  _id
                  name
                  oem {
                    _id
                    name
                    logo
                    thumbnail
                    backgroundColor
                    textColor
                    urlOem
                    slug
                    urlOemFacility
                  } 
                }
            }    
          }
   """;

String getOwnOemTicketById = """
          query getOwnOemTicketById (\$id: ID!) {
            getOwnOemTicketById(id: \$id) {
                _id
                title
                ticketId
                description
                notes
                status
                createdAt
                unread
                isMyTicket
                ticketChatChannels
                ticketInternalNotesChatChannels
                assignee {
                  _id
                  name 
                } 
                facility {
                  _id
                  name
                  urlOemFacility
                  totalMachines
                  totalOpenTickets
                  isQRCodeEnabled
                  generalAccessUrl
                }
                machine {
                    _id
                    name
                    serialNumber
                    description
                    documentationFiles
                    issues
                    image
                    thumbnail
                    totalOpenTickets
                    slug
                }
            }    
          }
   """;

String getOwnCustomerMachineById = """
          query getOwnCustomerMachineById (\$id: ID!) {
            getOwnCustomerMachineById(id: \$id) {
                _id
                name
                serialNumber
                description
                documentationFiles
                issues
                image
                thumbnail
                totalOpenTickets
                slug
                customers {
                  _id
                  name
                  oem {
                    _id
                    name
                    logo
                    thumbnail
                    backgroundColor
                    textColor
                    urlOem
                    slug
                    urlOemFacility
                  } 
                }
                documentTree {
                    _id
                    dataTreeFacilityMobile
                    {
                        _id
                        documents
                    }
                }
            }   
          }
   """;

String createOwnOemTicket = '''
              mutation createOwnOemTicket (\$input: InputCreateOwnOemTicket!) {
                  createOwnOemTicket (input: \$input) {
                     _id
                     title
                     status
                     createdAt
                     unread
                     isMyTicket
                     ticketChatChannels
                     ticketInternalNotesChatChannels
                     description
                     notes
                  }
              },
          ''';

String listOwnOemMachineTicketHistory = """
          query listOwnOemMachineTicketHistoryById (\$id: ID!) {
            listOwnOemMachineTicketHistoryById(id: \$id) {
              _id
                title
                ticketId
                description
                notes
                status
                createdAt
                unread
                isMyTicket
                ticketChatChannels
                ticketInternalNotesChatChannels
                facility {
                  _id
                  name 
                  urlOemFacility
                  totalMachines
                  totalOpenTickets
                  isQRCodeEnabled
                  generalAccessUrl
                }
                machine {
                    _id
                    name
                    serialNumber
                    description
                    documentationFiles
                    issues
                    image
                    thumbnail
                    totalOpenTickets
                    slug
                }
                user {
                    _id
                    name
                    username
                    role
                    email
                    access
                    userType
                    phone
                    about
                    userCredentialsSent
                    isOem
                    emailNotification
                    totalActiveTickets
                    organizationName
                    organizationType
                    chatToken
                    chatUUIDMetadata
                    chatKeys
                    chatUUID
                }
            }
          }
   """;

const String signS3Download = '''
              mutation _signS3Download (\$filename: String!) {
                  _signS3Download (filename: \$filename) {
                      id
                      signedRequest
                      url
                  }
              }
          ''';

String listOwnOemCustomers = r"""
          query listOwnOemCustomers {
            listOwnOemCustomers() {
              _id
              name 
              machines {
                _id
                name
                serialNumber
                description
                customers {
                    _id
                    name 
                } 
              }
            }
          }
   """;

String listOwnOemMachines = r"""
          query listOwnOemMachines {
            listOwnOemMachines() {
                  _id
                  name
                  serialNumber
                  description
                  customers {
                      _id
                      name 
                  } 
            }
          }
   """;

String listOwnOemFacilityUsers = """
          query listOwnOemFacilityUsers(\$facilityId: ID!) {
            listOwnOemFacilityUsers(facilityId: \$facilityId) {
              _id
              name
              username
              role
              email
              info
              access
              userType
              phone 
            }
          }
   """;

String listOwnOemSupportAccounts = r'''
    query listOwnOemSupportAccounts {
      listOwnOemSupportAccounts() {
         _id
        name
        username
        role
        email
        info
        access
        userType
        phone
        about
        userCredentialsSent
      }
    }
  ''';

String updateOwnOemTicket = '''
              mutation updateOwnOemTicket (\$input: InputUpdateOwnOemTicket!) {
                  updateOwnOemTicket (input: \$input) {
                    _id
                    title
                  }
              }
          ''';

String listOwnOemTemplates = r'''
    query listOwnOemTemplates {
       listOwnOemTemplates{
            _id
            templateData
            templateId
            oem {
                _id
                name
            }
        }
    }
  ''';

String listOwnOemSubmissions = r'''
    query listOwnOemSubmissions {
       listOwnOemSubmissions{
            _id
            url
            machine{
                _id
                name
                serialNumber
            }
            inspectionDate
            facility{
                _id
                name
            }
            user{
                _id
            }
            oem{
                _id
            }
            templateId
            templateName
            expired
        }
    }
  ''';

String getOwnOemFormUrlByTemplateId = '''
              query getOwnOemFormUrlByTemplateId (\$input: inputFormMetadata!) {
                  getOwnOemFormUrlByTemplateId (input: \$input)
              },
          ''';

String getOwnOemSubmissionById = '''
              query getOwnOemSubmissionById (\$submissionId: ID!) {
                  getOwnOemSubmissionById (submissionId: \$submissionId)
              }
          ''';

String deleteOwnOemSubmissionById = '''
              mutation deleteOwnOemSubmissionById (\$submissionId: ID!) {
                  deleteOwnOemSubmissionById (submissionId: \$submissionId)
              },
          ''';