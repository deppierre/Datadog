Set-AzContext -SubscriptionId f75404bd-6924-4d71-8d70-b8cb8d3b6c52
New-AzEventHubNamespace -ResourceGroupName CGG-HUB-RG-INF01 -NamespaceName CGG-PRD-HUB-DD01 -Location francecentral -SkuName Basic   
New-AzEventHub -ResourceGroupName CGG-HUB-RG-INF01 -NamespaceName CGG-PRD-HUB-DD01 -EventHubName CGG-PRD-HUB-DD01 -MessageRetentionInDays 1 -PartitionCount 2 
                                                                                                                                            
Set-AzContext -SubscriptionId ffb5a733-2560-42f4-a299-c73abf406e4a                                                                          
New-AzEventHubNamespace -ResourceGroupName CGL-DEV-RG-INF01 -NamespaceName CGL-DEV-HUB-DD01 -Location francecentral -SkuName Basic                   
New-AzEventHub -ResourceGroupName CGL-DEV-RG-INF01 -NamespaceName CGL-DEV-HUB-DD01 -EventHubName CGL-DEV-HUB-DD01 -MessageRetentionInDays 1 -PartitionCount 2
                                                     
Set-AzContext -SubscriptionId ee95aa77-106b-440b-8883-2444d8f3bc4c                                                                          
New-AzEventHubNamespace -ResourceGroupName CGL-UAT-RG-INF01 -NamespaceName CGL-UAT-HUB-DD01 -Location francecentral -SkuName Basic                         
New-AzEventHub -ResourceGroupName CGL-UAT-RG-INF01 -NamespaceName CGL-UAT-HUB-DD01 -EventHubName CGL-UAT-HUB-DD01 -MessageRetentionInDays 1 -PartitionCount 2 
                                                                                                                                            
Set-AzContext -SubscriptionId 87b720b3-fcb9-4bd5-8047-816efd16c823                                                                          
New-AzEventHubNamespace -ResourceGroupName CGP-DEV-RG-INF01 -NamespaceName CGP-DEV-HUB-DD01 -Location francecentral -SkuName Basic                           
New-AzEventHub -ResourceGroupName CGP-DEV-RG-INF01 -NamespaceName CGP-DEV-HUB-DD01 -EventHubName CGP-DEV-HUB-DD01 -MessageRetentionInDays 1 -PartitionCount 2 
                                                                                                                                            
Set-AzContext -SubscriptionId 03c795e0-8a46-47eb-ba0b-10c661d9469f                                                                          
New-AzEventHubNamespace -ResourceGroupName CGP-UAT-RG-INF01 -NamespaceName CGP-UAT-HUB-DD01 -Location francecentral -SkuName Basic                         
New-AzEventHub -ResourceGroupName CGP-UAT-RG-INF01 -NamespaceName CGP-UAT-HUB-DD01 -EventHubName CGP-UAT-HUB-DD01 -MessageRetentionInDays 1 -PartitionCount 2
                                                                                                                                            
Set-AzContext -SubscriptionId aba80970-1aa7-448a-860e-d309b4738c7f                                                                          
New-AzEventHubNamespace -ResourceGroupName CGL-PRD-RG-INF01 -NamespaceName CGL-PRD-HUB-DD01 -Location francecentral -SkuName Basic                        
New-AzEventHub -ResourceGroupName CGL-PRD-RG-INF01 -NamespaceName CGL-PRD-HUB-DD01 -EventHubName CGL-PRD-HUB-DD01 -MessageRetentionInDays 1 -PartitionCount 2
                                                                                                                                            
Set-AzContext -SubscriptionId 59d0136c-36de-44d6-b737-841c187b72b7                                                                          
New-AzEventHubNamespace -ResourceGroupName CGP-PRD-RG-INF01 -NamespaceName CGP-PRD-HUB-DD01 -Location francecentral -SkuName Basic                      
New-AzEventHub -ResourceGroupName CGP-PRD-RG-INF01 -NamespaceName CGP-PRD-HUB-DD01 -EventHubName CGP-PRD-HUB-DD01 -MessageRetentionInDays 1 -PartitionCount 2