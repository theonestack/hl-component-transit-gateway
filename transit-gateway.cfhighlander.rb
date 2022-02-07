CfhighlanderTemplate do
  
    Parameters do
        ComponentParam 'TransitGatewayName'
        ComponentParam 'AmazonSideAsn', '64512'
        ComponentParam 'AccountList', '',  type: 'CommaDelimitedList'
    end
end 