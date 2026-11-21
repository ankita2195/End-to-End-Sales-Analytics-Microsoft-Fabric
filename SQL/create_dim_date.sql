CREATE TABLE [analytics].[dim_date] (
    [order_date_key] INT          NOT NULL,
    [full_date]      DATE         NOT NULL,
    [year]           INT          NOT NULL,
    [month_number]   INT          NOT NULL,
    [month_name]     VARCHAR (20) NOT NULL,
    [quarter]        INT          NOT NULL,
    [day_of_week]    VARCHAR (20) NOT NULL,
    [is_weekend]     BIT          NOT NULL
);


GO