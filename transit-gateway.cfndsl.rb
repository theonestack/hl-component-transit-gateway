CloudFormation do

  default_tags = external_parameters.fetch(:default_tags, {})

  tags = []
  default_tags.each do |key, value|
    tags << {Key: key, Value: value}
  end unless default_tags.nil?

  auto_accept_shared_attachments = external_parameters.fetch('auto_accept_shared_attachments', 'enable')
  default_route_table_association = external_parameters.fetch('default_route_table_association', 'enable')
  default_route_table_propagation = external_parameters.fetch('default_route_table_propagation', 'enable')
  dns_support = external_parameters.fetch('dns_support', 'enable')
  vpn_ecmp_support = external_parameters.fetch('vpn_ecmp_support', 'enable')

  EC2_TransitGateway(:TransitGateway) do
    Description FnJoin(' ', [Ref(:TransitGatewayName), '- Shared Transit Gateway'])
    AmazonSideAsn Ref(:AmazonSideAsn)
    AutoAcceptSharedAttachments auto_accept_shared_attachments
    DefaultRouteTableAssociation default_route_table_association
    DefaultRouteTablePropagation default_route_table_propagation
    DnsSupport dns_support
    MulticastSupport 'disable'
    VpnEcmpSupport vpn_ecmp_support
    Tags tags unless tags.empty?
  end

  Output(:TransitGateway) do
    Value(Ref(:TransitGateway))
    Export FnSub("${TransitGatewayName}-#{external_parameters[:component_name]}-TransitGateway")
  end

  EC2_TransitGatewayRouteTable(:DefaultRouteTable) do
    TransitGatewayId Ref(:TransitGateway)
  end
  Output(:DefaultRouteTable) do
    Value(Ref(:DefaultRouteTable))
    Export FnSub("${TransitGatewayName}-#{external_parameters[:component_name]}-DefaultRouteTable")
  end

  Condition(:ShareTransitGateway, FnEquals(Ref(:EnableSharing), 'true'))

  RAM_ResourceShare(:ResourceShare) do
    Condition(:ShareTransitGateway)
    AllowExternalPrincipals true
    Name Ref(:TransitGatewayName)
    ResourceArns ([
      FnSub('arn:aws:ec2:${AWS::Region}:${AWS::AccountId}:transit-gateway/${TransitGateway}')
    ])
    Principals Ref(:AccountList)
  end
end
